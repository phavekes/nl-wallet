//! This module contains `DigidConnector` which supports user authentication through Digid.
//!

use base64::{engine::general_purpose::URL_SAFE_NO_PAD, Engine};
use futures::future::TryFutureExt;
use openid::{error as openid_errors, Bearer, Client, Options, Token};
use serde::Deserialize;
use url::{form_urlencoded::Serializer as FormSerializer, Url};

use wallet_common::utils::random_bytes;

use crate::{
    config::DigidConfiguration,
    openid::{OpenIdClientExtensions, UrlExtension},
};

const PARAM_CODE_CHALLENGE: &str = "code_challenge";
const PARAM_CODE_CHALLENGE_METHOD: &str = "code_challenge_method";
const PARAM_GRANT_TYPE: &str = "grant_type";
const PARAM_CODE: &str = "code";
const PARAM_STATE: &str = "state";
const PARAM_REDIRECT_URI: &str = "redirect_uri";
const PARAM_CLIENT_ID: &str = "client_id";
const PARAM_CODE_VERIFIER: &str = "code_verifier";

const CHALLENGE_METHOD_S256: &str = "S256";
const GRANT_TYPE_AUTHORIZATION_CODE: &str = "authorization_code";

const WALLET_CLIENT_REDIRECT_URI: &str = "walletdebuginteraction://wallet.edi.rijksoverheid.nl/authentication";

type Result<T> = std::result::Result<T, Error>;

#[derive(Debug, thiserror::Error)]
pub enum Error {
    #[error("could not perform openid operation: {0}")]
    OpenId(#[from] openid_errors::Error),
    #[error("invalid redirect URI received")]
    RedirectUriMismatch,
    #[error("invalid state token received")]
    StateTokenMismatch,
    #[error("could not get BSN from PID issuer: {0}")]
    PidIssuer(#[from] reqwest::Error),
    #[error("could not get BSN from PID issuer: {0} - Response body: {1}")]
    PidIssuerResponse(#[source] reqwest::Error, String),
}

#[derive(Deserialize)]
struct BsnResponse {
    bsn: String,
}

pub struct DigidConnector {
    client: Client,
    session_state: Option<DigidSessionState>,
    pid_issuer_url: Url,
}

struct DigidSessionState {
    /// Cache for the PKCE verifier
    pkce_verifier: String,
    /// Options
    options: Options,
}

impl DigidConnector {
    pub async fn create(conf: &DigidConfiguration) -> Result<Self> {
        let client = Client::discover_with_client(
            reqwest::Client::new(),
            conf.digid_client_id.clone(),
            None,
            Some(WALLET_CLIENT_REDIRECT_URI.to_string()),
            conf.digid_url.clone(),
        )
        .await?;
        Ok(Self {
            client,
            session_state: None,
            pid_issuer_url: conf.pid_issuer_url.clone(),
        })
    }

    /// Construct the authorization url, where the user must be redirected
    pub fn get_digid_authorization_url(&mut self) -> Result<Url> {
        let scopes_supported: String = self
            .client
            .config()
            .scopes_supported
            .as_ref()
            .unwrap_or(&vec![])
            .join(" ");
        let nonce = URL_SAFE_NO_PAD.encode(random_bytes(16));
        let csrf_token = URL_SAFE_NO_PAD.encode(random_bytes(16));

        let options: Options = Options {
            scope: Some(scopes_supported),
            nonce: Some(nonce),
            state: Some(csrf_token),
            ..Default::default()
        };

        // Generate a random 128-byte code verifier (must be between 43 and 128 bytes)
        let code_verifier = pkce::code_verifier(128);

        // Generate an encrypted code challenge accordingly
        let code_challenge = pkce::code_challenge(&code_verifier);

        // Generate PKCE verifier
        let pkce_verifier = String::from_utf8(code_verifier).expect("Generated PKCE verifier is not valid UTF-8");

        let auth_url = {
            let mut auth_url = self.client.auth_url(&options);
            // Add PKCE challenge
            auth_url
                .query_pairs_mut()
                .append_pair(PARAM_CODE_CHALLENGE, &code_challenge)
                .append_pair(PARAM_CODE_CHALLENGE_METHOD, CHALLENGE_METHOD_S256);

            auth_url
        };

        // Remember session state
        self.session_state = Some(DigidSessionState { pkce_verifier, options });

        Ok(auth_url)
    }

    /// Create token request body with PKCS code_verifier.
    /// NOTE: The `openid` crate does not support PKCE, so it is implemented here.
    fn get_token_request(&self, authorization_code: &str, pkce_verifier: &str) -> String {
        let mut body = FormSerializer::new(String::new());
        body.append_pair(PARAM_GRANT_TYPE, GRANT_TYPE_AUTHORIZATION_CODE);
        body.append_pair(PARAM_CODE, authorization_code);

        if let Some(ref redirect_uri) = self.client.redirect_uri {
            body.append_pair(PARAM_REDIRECT_URI, redirect_uri);
        }

        body.append_pair(PARAM_CLIENT_ID, &self.client.client_id);
        body.append_pair(PARAM_CODE_VERIFIER, pkce_verifier); // TODO error handling

        body.finish()
    }

    pub async fn get_access_token(&mut self, redirect_url: Url) -> Result<String> {
        if !redirect_url.as_str().starts_with(WALLET_CLIENT_REDIRECT_URI) {
            return Err(Error::RedirectUriMismatch);
        }

        let DigidSessionState { options, pkce_verifier } = self.session_state.take().expect("No session state found");

        // TODO check redirect_url for error and error_description fields, if so there was an error.

        let state = redirect_url
            .find_param(PARAM_STATE)
            .expect("Missing 'state' query parameter");

        // Verify the state token matches the csrf_token
        if &state != options.state.as_ref().expect("No CSRF Token found") {
            return Err(Error::StateTokenMismatch);
        }

        let authorization_code = redirect_url
            .find_param(PARAM_CODE)
            .expect("Missing 'code' query parameter");

        let bearer_token = {
            let body = self.get_token_request(&authorization_code, &pkce_verifier);
            self.client
                .invoke_token_endpoint(body)
                .await
                .map_err(openid_errors::Error::from)?
        };

        self.validate_id_token(&bearer_token, &options)?;

        Ok(bearer_token.access_token)
    }

    pub async fn issue_pid(&mut self, url: Url) -> Result<String> {
        let access_token: String = self.get_access_token(url).await?;

        let url = self
            .pid_issuer_url
            .join("extract_bsn")
            .expect("Could not create \"extract_bsn\" URL from PID issuer base URL");

        let bsn_response = self
            .client
            .http_client
            .post(url)
            .bearer_auth(access_token)
            .send()
            .map_err(Error::from)
            .and_then(|response| async {
                // Try to get the body from any 4xx or 5xx error responses,
                // in order to create an Error::PidIssuerResponse.
                // TODO: Implement proper JSON-based error reporting
                //       for the mock PID issuer.
                match response.error_for_status_ref() {
                    Ok(_) => Ok(response),
                    Err(error) => {
                        let error = match response.text().await.ok() {
                            Some(body) => Error::PidIssuerResponse(error, body),
                            None => Error::PidIssuer(error),
                        };

                        Err(error)
                    }
                }
            })
            .await?
            .json::<BsnResponse>()
            .await?;

        Ok(bsn_response.bsn)
    }

    fn validate_id_token(&self, bearer_token: &Bearer, options: &Options) -> Result<()> {
        let token: Token = bearer_token.clone().into();
        let mut id_token = token.id_token.expect("No id_token found");
        self.client.decode_token(&mut id_token)?;

        self.client
            .validate_custom_token(&id_token, options.nonce.as_deref(), options.max_age.as_ref())?;
        Ok(())
    }
}
