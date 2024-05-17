use std::borrow::Cow;

use sentry::{ClientInitGuard, ClientOptions};
use serde::Deserialize;

#[derive(Clone, Deserialize)]
pub struct Sentry {
    pub dsn: String,
    pub environment: Option<String>,
}

impl Sentry {
    /// Initialize Sentry and return the [`ClientInitGuard`].
    /// [release] must be set to `sentry::release_name!()` from the `main.rs` of the application, so that the release
    /// matches the main crate.
    #[must_use = "this value must be retained during the lifetime of the application"]
    pub fn init(&self, release: Option<Cow<'static, str>>) -> ClientInitGuard {
        sentry::init((
            self.dsn.clone(),
            ClientOptions {
                release,
                environment: self.environment.as_ref().map(|e| Cow::from(e.clone())),
                debug: cfg!(debug_assertions),
                ..Default::default()
            },
        ))
    }
}

/// Helper macro, to initialize Sentry from an `Option<Sentry>` reference.
/// This macro ensures that the `release_name` of the main application is used.
/// When the argument is `None`, sentry will not be initialized.
#[macro_export]
macro_rules! try_init_sentry {
    ($x:expr) => {
        $x.as_ref().map(|sentry| sentry.init(sentry::release_name!()))
    };
}
