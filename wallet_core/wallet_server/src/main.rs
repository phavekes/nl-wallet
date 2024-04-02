use anyhow::Result;

use wallet_server::{
    pid::{attributes::BrpPidAttributeService, brp::client::HttpBrpClient},
    server,
    settings::Settings,
    store::SessionStores,
};

#[tokio::main]
async fn main() -> Result<()> {
    // Initialize tracing.
    tracing_subscriber::fmt::init();

    let settings = Settings::new()?;

    let sessions = SessionStores::init(settings.store_url.clone()).await?;

    // This will block until the server shuts down.
    #[cfg(feature = "issuance")]
    server::serve_full(
        BrpPidAttributeService::new(
            HttpBrpClient::new(settings.issuer.brp_server.clone()),
            settings.issuer.digid.issuer_url.clone(),
            settings.issuer.digid.bsn_privkey.clone(),
            settings.issuer.digid.trust_anchors.clone(),
            settings.issuer.certificates(),
        )?,
        settings,
        sessions,
    )
    .await?;

    #[cfg(not(feature = "issuance"))]
    server::serve_disclosure(settings, sessions).await?;

    Ok(())
}
