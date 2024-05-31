use anyhow::Result;
use wallet_server::{
    pid::{attributes::BrpPidAttributeService, brp::client::HttpBrpClient},
    server,
    settings::Settings,
    store::SessionStores,
};

// Cannot use #[tokio::main], see: https://docs.sentry.io/platforms/rust/#async-main-function
fn main() -> Result<()> {
    // Initialize tracing.
    tracing_subscriber::fmt::init();

    let settings = Settings::new_custom("wallet_server.toml", "wallet_server")?;

    // Retain [`ClientInitGuard`]
    let _guard = settings
        .sentry
        .as_ref()
        .map(|sentry| sentry.init(sentry::release_name!()));

    tokio::runtime::Builder::new_multi_thread()
        .enable_all()
        .build()?
        .block_on(async { async_main(settings).await })
}

async fn async_main(settings: Settings) -> Result<()> {
    let storage_settings = &settings.storage;
    let sessions = SessionStores::init(storage_settings.url.clone(), storage_settings.into()).await?;

    // This will block until the server shuts down.
    server::wallet_server::serve(
        BrpPidAttributeService::new(
            HttpBrpClient::new(settings.issuer.brp_server.clone()),
            settings.issuer.digid.issuer_url.clone(),
            settings.issuer.digid.bsn_privkey.clone(),
            settings.issuer.digid.trust_anchors.clone(),
            settings.issuer.certificates(),
        )?,
        settings,
        sessions.disclosure,
        sessions.issuance,
    )
    .await?;

    Ok(())
}
