// Data structures defined in ISO 18013-5, 23220-3 and -4
pub mod iso;
pub use iso::*;

// Functionality for the three main agents
pub mod holder;
pub mod issuer;
pub mod verifier;

// Data types shared between agents
pub mod issuer_shared;

pub mod server_state;

/// General code used throughout the crate.
pub mod utils;

/// Errors that can happen throughout the crate.
pub mod errors;
pub use errors::*;

#[cfg(any(test, feature = "mock"))]
pub mod mock;

#[cfg(any(test, feature = "examples"))]
pub mod examples;
