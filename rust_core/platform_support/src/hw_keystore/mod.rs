#[cfg(feature = "hardware")]
pub mod hardware;

#[cfg(feature = "software")]
pub mod software;

#[cfg(feature = "integration-test")]
pub mod integration_test;

use thiserror::Error;
use wallet_shared::account::signing_key::SecureEcdsaKey;

#[derive(Debug, Error)]
pub enum HardwareKeyStoreError {
    #[error(transparent)]
    KeyStoreError(#[from] KeyStoreError),
    #[error("Error decoding public key from hardware: {0}")]
    PublicKeyError(#[from] p256::pkcs8::spki::Error),
}

// implementation of KeyStoreError from UDL, only with "hardware" flag
#[derive(Debug, Error)]
pub enum KeyStoreError {
    #[error("Key error: {reason}")]
    KeyError { reason: String },
    #[error("Bridging error: {reason}")]
    BridgingError { reason: String },
}

/// Contract for ECDSA private keys suitable for use in the wallet, as the authentication key for the WP.
/// Should be sufficiently secured e.g. through Android's TEE/StrongBox or Apple's SE.
/// Handles to private keys are requested through [`PlatformSigningKey::signing_key()`].
pub trait PlatformEcdsaKey: SecureEcdsaKey {
    fn signing_key(identifier: &str) -> Result<Self, HardwareKeyStoreError>
    where
        Self: Sized;

    // from SecureSigningKey: verifying_key(), try_sign() and sign() methods
}

// if the hardware feature is enabled, prefer HardwareSigningKey
#[cfg(feature = "hardware")]
pub type PreferredPlatformEcdsaKey = crate::hw_keystore::hardware::HardwareEcdsaKey;

// otherwise if the software feature is enabled, prefer SoftwareSigningKey
#[cfg(all(not(feature = "hardware"), feature = "software"))]
pub type PreferredPlatformEcdsaKey = crate::hw_keystore::software::SoftwareEcdsaKey;

// otherwise just just alias the Never type
#[cfg(not(any(feature = "hardware", feature = "software")))]
pub type PreferredPlatformEcdsaKey = never::Never;
