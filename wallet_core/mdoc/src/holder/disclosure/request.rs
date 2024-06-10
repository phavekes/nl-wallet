use chrono::{DateTime, Utc};
use indexmap::IndexSet;
use wallet_common::generator::Generator;
use webpki::TrustAnchor;

use crate::{
    device_retrieval::{DeviceRequest, DocRequest, ReaderAuthenticationKeyed},
    engagement::SessionTranscript,
    errors::Result,
    holder::HolderError,
    identifiers::{AttributeIdentifier, AttributeIdentifierHolder},
    utils::{
        cose::ClonePayload,
        reader_auth::ReaderRegistration,
        serialization::{self, CborSeq, TaggedBytes},
        x509::{Certificate, CertificateType, CertificateUsage},
    },
    ItemsRequest,
};

impl DeviceRequest {
    /// Returns `true` if this request has any attributes at all.
    pub fn has_attributes(&self) -> bool {
        self.doc_requests
            .iter()
            .flat_map(|doc_request| doc_request.items_request.0.name_spaces.values())
            .any(|name_space| !name_space.is_empty())
    }

    /// Verify reader authentication, if present.
    /// Note that since each DocRequest carries its own reader authentication, the spec allows the
    /// the DocRequests to be signed by distinct readers. TODO maybe support this (PVW-2368).
    /// For now, this function requires either none of the DocRequests to be signed, or all of them
    /// by the same reader.
    pub fn verify(
        &self,
        session_transcript: &SessionTranscript,
        time: &impl Generator<DateTime<Utc>>,
        trust_anchors: &[TrustAnchor],
    ) -> Result<Option<(Certificate, ReaderRegistration)>> {
        // If there are no doc requests or none of them have reader authentication, return `None`.
        if self.doc_requests.iter().all(|d| d.reader_auth.is_none()) {
            return Ok(None);
        }

        // Otherwise, all of the doc requests need reader authentication.
        if self.doc_requests.iter().any(|d| d.reader_auth.is_none()) {
            return Err(HolderError::ReaderAuthMissing.into());
        }

        // Verify all `DocRequest` entries and make sure the resulting certificates are all exactly equal.
        let certificate = self
            .doc_requests
            .iter()
            .try_fold(None, {
                |result_cert, doc_request| -> Result<_> {
                    // This `.unwrap()` is safe, because `.verify()` will only return `None`
                    // if `reader_auth` is absent, the presence of which we checked above.
                    let doc_request_cert = doc_request.verify(session_transcript, time, trust_anchors)?.unwrap();

                    // If there is a certificate from a previous iteration, compare our certificate to that.
                    if let Some(result_cert) = result_cert {
                        if doc_request_cert != result_cert {
                            return Err(HolderError::ReaderAuthsInconsistent.into());
                        }
                    }

                    Ok(doc_request_cert.into())
                }
            })?
            .unwrap(); // This `.unwrap()` is safe for the same reason stated above.

        // Extract `ReaderRegistration` from the one certificate.
        let reader_registration = match CertificateType::from_certificate(&certificate).map_err(HolderError::from)? {
            CertificateType::ReaderAuth(Some(reader_registration)) => *reader_registration,
            _ => return Err(HolderError::NoReaderRegistration(certificate).into()),
        };

        // Verify that the requested attributes are included in the reader authentication.
        reader_registration
            .verify_requested_attributes(self.items_requests())
            .map_err(HolderError::from)?;

        Ok((certificate, reader_registration).into())
    }

    pub fn items_requests(&self) -> impl Iterator<Item = &ItemsRequest> + Clone {
        self.doc_requests.iter().map(|doc_request| &doc_request.items_request.0)
    }
}

impl<'a, T: IntoIterator<Item = &'a ItemsRequest> + Clone> AttributeIdentifierHolder for T {
    fn attribute_identifiers(&self) -> IndexSet<AttributeIdentifier> {
        self.clone()
            .into_iter()
            .flat_map(|items_request| items_request.attribute_identifiers())
            .collect()
    }
}

impl DocRequest {
    pub fn verify(
        &self,
        session_transcript: &SessionTranscript,
        time: &impl Generator<DateTime<Utc>>,
        trust_anchors: &[TrustAnchor],
    ) -> Result<Option<Certificate>> {
        // If reader authentication is present, verify it and return the certificate.
        self.reader_auth
            .as_ref()
            .map(|reader_auth| {
                // Reconstruct the reader authentication bytes for this `DocRequest`,
                // based on the item requests and session transcript.
                let reader_auth_payload = ReaderAuthenticationKeyed::new(session_transcript, &self.items_request);
                let reader_auth_payload = TaggedBytes(CborSeq(reader_auth_payload));

                // Perform verification and return the `Certificate`.
                let cose = reader_auth.clone_with_payload(serialization::cbor_serialize(&reader_auth_payload)?);
                cose.verify_against_trust_anchors(CertificateUsage::ReaderAuth, time, trust_anchors)?;
                let cert = cose.signing_cert()?;

                Ok(cert)
            })
            .transpose()
    }
}

#[cfg(test)]
mod tests {
    use std::num::NonZeroU8;

    use assert_matches::assert_matches;

    use indexmap::IndexMap;
    use rstest::rstest;

    use wallet_common::{generator::TimeGenerator, trust_anchor::DerTrustAnchor};

    use crate::{
        errors::Error,
        holder::{DisclosureRequestMatch, ProposedDocument},
        iso::mdocs::{Attributes, IssuerNameSpaces, IssuerSignedItem},
        server_keys::KeyPair,
        software_key_factory::SoftwareKeyFactory,
        test::{
            data::{addr_street, empty, pid_family_name, pid_full_name, pid_given_name},
            TestDocument, TestDocuments,
        },
        unsigned::Entry,
        verifier::SessionType,
    };

    use super::{super::test::*, *};

    #[tokio::test]
    async fn test_device_request_verify() {
        // Create two certificates and private keys.
        let ca = KeyPair::generate_reader_mock_ca().unwrap();
        let der_trust_anchors = [DerTrustAnchor::from_der(ca.certificate().as_bytes().to_vec()).unwrap()];
        let reader_registration = ReaderRegistration::new_mock();
        let private_key1 = ca.generate_reader_mock(reader_registration.clone().into()).unwrap();
        let private_key2 = ca.generate_reader_mock(reader_registration.clone().into()).unwrap();

        let session_transcript = create_basic_session_transcript(SessionType::SameDevice);

        // Create an empty `ItemsRequest` and generate `DeviceRequest` with two `DocRequest`s
        // from it, each signed with the same certificate.
        let items_request = emtpy_items_request();

        let device_request = DeviceRequest::from_doc_requests(vec![
            create_doc_request(items_request.clone(), &session_transcript, &private_key1).await,
            create_doc_request(items_request.clone(), &session_transcript, &private_key1).await,
        ]);

        // Verifying this `DeviceRequest` should succeed and return the `ReaderRegistration`.
        let trust_anchors = der_trust_anchors
            .iter()
            .map(|anchor| (&anchor.owned_trust_anchor).into())
            .collect::<Vec<_>>();

        let verified_reader_registration = device_request
            .verify(&session_transcript, &TimeGenerator, &trust_anchors)
            .expect("Could not verify DeviceRequest");

        assert_eq!(
            verified_reader_registration,
            Some((private_key1.certificate().clone(), reader_registration))
        );

        // Verifying a `DeviceRequest` that has no reader auth at all should succeed and return `None`.
        let device_request = DeviceRequest::from_items_requests(vec![items_request.clone(), items_request.clone()]);

        let no_reader_registration = device_request
            .verify(&session_transcript, &TimeGenerator, &trust_anchors)
            .expect("Could not verify DeviceRequest");

        assert!(no_reader_registration.is_none());

        // Generate `DeviceRequest` with two `DocRequest`s, each signed
        // with a different key and including a different certificate.
        let device_request = DeviceRequest::from_doc_requests(vec![
            create_doc_request(items_request.clone(), &session_transcript, &private_key1).await,
            create_doc_request(items_request, &session_transcript, &private_key2).await,
        ]);

        // Verifying this `DeviceRequest` should result in a `HolderError::ReaderAuthsInconsistent` error.
        let error = device_request
            .verify(&session_transcript, &TimeGenerator, &trust_anchors)
            .expect_err("Verifying DeviceRequest should have resulted in an error");

        assert_matches!(error, Error::Holder(HolderError::ReaderAuthsInconsistent));
    }

    #[rstest]
    #[case(empty(), empty(), candidates(empty()))]
    #[case(pid_full_name(), pid_full_name(), candidates(pid_full_name()))]
    #[case(pid_given_name(), pid_given_name() + pid_given_name(), candidates(pid_given_name()))]
    #[case(pid_given_name() + pid_given_name(), pid_given_name(), candidates(pid_given_name() + pid_given_name()))]
    #[case(pid_full_name() + pid_given_name() + addr_street(), addr_street(), candidates(addr_street()))]
    #[case(pid_full_name() + pid_given_name() + addr_street(), pid_given_name(), candidates(pid_given_name() + pid_given_name()))]
    #[case(pid_full_name() + pid_given_name() + addr_street(), empty(), candidates(empty()))]
    #[case(empty(), pid_given_name(), missing_attributes(pid_given_name()))]
    #[case(
        empty(),
        pid_given_name() + addr_street(),
        missing_attributes(pid_given_name() + addr_street())
    )]
    #[case(pid_given_name(), pid_full_name(), missing_attributes(pid_family_name()))]
    #[case(pid_full_name(), addr_street(), missing_attributes(addr_street()))]
    #[tokio::test]
    async fn test_match_stored_documents(
        #[case] stored_documents: TestDocuments,
        #[case] requested_documents: TestDocuments,
        #[case] expected_match: ExpectedDisclosureRequestMatch,
    ) {
        let ca = KeyPair::generate_issuer_mock_ca().unwrap();
        let key_factory = SoftwareKeyFactory::default();

        let mut mdoc_data_source = MockMdocDataSource::new();
        for document in stored_documents.into_iter() {
            mdoc_data_source
                .mdocs
                .push(document.sign(&ca, &key_factory, NonZeroU8::new(1).unwrap()).await);
        }

        let device_request = DeviceRequest::from(requested_documents);

        let session_transcript = create_basic_session_transcript(SessionType::SameDevice);
        let match_result =
            DisclosureRequestMatch::new(device_request.items_requests(), &mdoc_data_source, &session_transcript)
                .await
                .expect("Could not match device request with stored documents");

        let match_result: ExpectedDisclosureRequestMatch = match_result.into();
        assert_eq!(match_result, expected_match);
    }

    #[tokio::test]
    async fn test_doc_request_verify() {
        // Create a CA, certificate and private key and trust anchors.
        let ca = KeyPair::generate_reader_mock_ca().unwrap();
        let reader_registration = ReaderRegistration::new_mock();
        let private_key = ca.generate_reader_mock(reader_registration.into()).unwrap();
        let der_trust_anchor = DerTrustAnchor::from_der(ca.certificate().as_bytes().to_vec()).unwrap();

        // Create a basic session transcript, item request and a `DocRequest`.
        let session_transcript = create_basic_session_transcript(SessionType::SameDevice);
        let items_request = emtpy_items_request();
        let doc_request = create_doc_request(items_request.clone(), &session_transcript, &private_key).await;

        // Verification of the `DocRequest` should succeed and return the certificate contained within it.
        let certificate = doc_request
            .verify(
                &session_transcript,
                &TimeGenerator,
                &[(&der_trust_anchor.owned_trust_anchor).into()],
            )
            .expect("Could not verify DeviceRequest");

        assert_matches!(certificate, Some(cert) if cert == private_key.into());

        let other_ca = KeyPair::generate_reader_mock_ca().unwrap();
        let other_der_trust_anchor = DerTrustAnchor::from_der(other_ca.certificate().as_bytes().to_vec()).unwrap();
        let error = doc_request
            .verify(
                &session_transcript,
                &TimeGenerator,
                &[(&other_der_trust_anchor.owned_trust_anchor).into()],
            )
            .expect_err("Verifying DeviceRequest should have resulted in an error");

        assert_matches!(error, Error::Cose(_));

        // Verifying a `DocRequest` that has no reader auth should succeed and return `None`.
        let doc_request = DocRequest {
            items_request: items_request.into(),
            reader_auth: None,
        };

        let no_certificate = doc_request
            .verify(
                &session_transcript,
                &TimeGenerator,
                &[(&der_trust_anchor.owned_trust_anchor).into()],
            )
            .expect("Could not verify DeviceRequest");

        assert!(no_certificate.is_none());
    }

    #[derive(Debug, PartialEq)]
    enum ExpectedDisclosureRequestMatch {
        Candidates(TestDocuments),
        MissingAttributes(IndexSet<AttributeIdentifier>),
    }

    fn candidates(candidates: TestDocuments) -> ExpectedDisclosureRequestMatch {
        ExpectedDisclosureRequestMatch::Candidates(candidates)
    }
    fn missing_attributes(missing_attributes: TestDocuments) -> ExpectedDisclosureRequestMatch {
        ExpectedDisclosureRequestMatch::MissingAttributes(missing_attributes.attribute_identifiers())
    }

    impl<T> From<DisclosureRequestMatch<T>> for ExpectedDisclosureRequestMatch {
        fn from(value: DisclosureRequestMatch<T>) -> Self {
            match value {
                DisclosureRequestMatch::Candidates(candidates) => {
                    let candidates: Vec<TestDocument> = candidates
                        .into_iter()
                        .flat_map(|(_, namespaces)| namespaces)
                        .map(convert_proposed_document)
                        .collect();
                    Self::Candidates(candidates.into())
                }
                DisclosureRequestMatch::MissingAttributes(missing) => {
                    Self::MissingAttributes(missing.into_iter().collect())
                }
            }
        }
    }

    fn convert_proposed_document<I>(
        ProposedDocument {
            doc_type,
            issuer_signed,
            ..
        }: ProposedDocument<I>,
    ) -> TestDocument {
        let name_spaces = issuer_signed.name_spaces.expect("Expected namespaces");

        TestDocument {
            doc_type,
            namespaces: convert_namespaces(name_spaces),
        }
    }

    fn convert_namespaces(namespaces: IssuerNameSpaces) -> IndexMap<String, Vec<Entry>> {
        namespaces
            .into_inner()
            .into_iter()
            .map(|(namespace, attributes)| (namespace, convert_attributes(attributes)))
            .collect()
    }

    fn convert_attributes(attributes: Attributes) -> Vec<Entry> {
        attributes.into_inner().into_iter().map(convert_attribute).collect()
    }

    fn convert_attribute(attribute: TaggedBytes<IssuerSignedItem>) -> Entry {
        Entry {
            name: attribute.0.element_identifier,
            value: attribute.0.element_value,
        }
    }
}
