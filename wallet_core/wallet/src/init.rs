use platform_support::hw_keystore::hardware::{HardwareEcdsaKey, HardwareEncryptionKey};

use crate::{
    account_server::RemoteAccountServerClient,
    config::{Configuration, LocalConfigurationRepository},
    storage::DatabaseStorage,
    wallet::WalletInitError,
};

pub type Wallet = crate::wallet::Wallet<
    LocalConfigurationRepository,
    DatabaseStorage<HardwareEncryptionKey>,
    HardwareEcdsaKey,
    RemoteAccountServerClient,
>;

pub async fn init_wallet() -> Result<Wallet, WalletInitError> {
    // The initial configuration serves as the hardcoded fallback, for
    // when the app starts and no configuration from the Wallet Provider
    // is cached yet.
    let config = LocalConfigurationRepository::new_with_initial(Configuration::default);

    Wallet::init_all(config).await
}
