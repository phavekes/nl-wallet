#![allow(
    non_camel_case_types,
    unused,
    clippy::redundant_closure,
    clippy::useless_conversion,
    clippy::unit_arg,
    clippy::double_parens,
    non_snake_case,
    clippy::too_many_arguments
)]
// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`@ 1.78.0.

use crate::api::*;
use core::panic::UnwindSafe;
use flutter_rust_bridge::*;
use std::ffi::c_void;
use std::sync::Arc;

// Section: imports

use crate::models::config::FlutterConfiguration;
use crate::models::pin::PinValidationResult;
use crate::models::process_uri_event::PidIssuanceEvent;
use crate::models::process_uri_event::ProcessUriEvent;
use crate::models::unlock::WalletUnlockResult;

// Section: wire functions

fn wire_init_impl(port_: MessagePort) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "init",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || move |task_callback| init(),
    )
}
fn wire_is_initialized_impl(port_: MessagePort) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "is_initialized",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || move |task_callback| Ok(is_initialized()),
    )
}
fn wire_is_valid_pin_impl(port_: MessagePort, pin: impl Wire2Api<String> + UnwindSafe) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "is_valid_pin",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_pin = pin.wire2api();
            move |task_callback| is_valid_pin(api_pin)
        },
    )
}
fn wire_set_lock_stream_impl(port_: MessagePort) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "set_lock_stream",
            port: Some(port_),
            mode: FfiCallMode::Stream,
        },
        move || move |task_callback| set_lock_stream(task_callback.stream_sink()),
    )
}
fn wire_clear_lock_stream_impl(port_: MessagePort) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "clear_lock_stream",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || move |task_callback| clear_lock_stream(),
    )
}
fn wire_set_configuration_stream_impl(port_: MessagePort) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "set_configuration_stream",
            port: Some(port_),
            mode: FfiCallMode::Stream,
        },
        move || move |task_callback| set_configuration_stream(task_callback.stream_sink()),
    )
}
fn wire_clear_configuration_stream_impl(port_: MessagePort) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "clear_configuration_stream",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || move |task_callback| clear_configuration_stream(),
    )
}
fn wire_unlock_wallet_impl(port_: MessagePort, pin: impl Wire2Api<String> + UnwindSafe) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "unlock_wallet",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_pin = pin.wire2api();
            move |task_callback| unlock_wallet(api_pin)
        },
    )
}
fn wire_lock_wallet_impl(port_: MessagePort) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "lock_wallet",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || move |task_callback| lock_wallet(),
    )
}
fn wire_has_registration_impl(port_: MessagePort) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "has_registration",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || move |task_callback| has_registration(),
    )
}
fn wire_register_impl(port_: MessagePort, pin: impl Wire2Api<String> + UnwindSafe) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "register",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_pin = pin.wire2api();
            move |task_callback| register(api_pin)
        },
    )
}
fn wire_create_pid_issuance_redirect_uri_impl(port_: MessagePort) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "create_pid_issuance_redirect_uri",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || move |task_callback| create_pid_issuance_redirect_uri(),
    )
}
fn wire_process_uri_impl(port_: MessagePort, uri: impl Wire2Api<String> + UnwindSafe) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "process_uri",
            port: Some(port_),
            mode: FfiCallMode::Stream,
        },
        move || {
            let api_uri = uri.wire2api();
            move |task_callback| process_uri(api_uri, task_callback.stream_sink())
        },
    )
}
// Section: wrapper structs

// Section: static checks

// Section: allocate functions

// Section: related functions

// Section: impl Wire2Api

pub trait Wire2Api<T> {
    fn wire2api(self) -> T;
}

impl<T, S> Wire2Api<Option<T>> for *mut S
where
    *mut S: Wire2Api<T>,
{
    fn wire2api(self) -> Option<T> {
        (!self.is_null()).then(|| self.wire2api())
    }
}

impl Wire2Api<u8> for u8 {
    fn wire2api(self) -> u8 {
        self
    }
}

// Section: impl IntoDart

impl support::IntoDart for FlutterConfiguration {
    fn into_dart(self) -> support::DartAbi {
        vec![
            self.inactive_lock_timeout.into_dart(),
            self.background_lock_timeout.into_dart(),
        ]
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for FlutterConfiguration {}

impl support::IntoDart for PidIssuanceEvent {
    fn into_dart(self) -> support::DartAbi {
        match self {
            Self::Authenticating => 0,
            Self::Success => 1,
            Self::Error => 2,
        }
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for PidIssuanceEvent {}
impl support::IntoDart for PinValidationResult {
    fn into_dart(self) -> support::DartAbi {
        match self {
            Self::Ok => 0,
            Self::TooFewUniqueDigits => 1,
            Self::SequentialDigits => 2,
            Self::OtherIssue => 3,
        }
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for PinValidationResult {}
impl support::IntoDart for ProcessUriEvent {
    fn into_dart(self) -> support::DartAbi {
        match self {
            Self::PidIssuance(field0) => vec![0.into_dart(), field0.into_dart()],
        }
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for ProcessUriEvent {}

impl support::IntoDart for WalletUnlockResult {
    fn into_dart(self) -> support::DartAbi {
        match self {
            Self::Ok => vec![0.into_dart()],
            Self::IncorrectPin {
                leftover_attempts,
                is_final_attempt,
            } => vec![
                1.into_dart(),
                leftover_attempts.into_dart(),
                is_final_attempt.into_dart(),
            ],
            Self::Timeout { timeout_millis } => vec![2.into_dart(), timeout_millis.into_dart()],
            Self::Blocked => vec![3.into_dart()],
        }
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for WalletUnlockResult {}
// Section: executor

support::lazy_static! {
    pub static ref FLUTTER_RUST_BRIDGE_HANDLER: support::DefaultHandler = Default::default();
}

#[cfg(not(target_family = "wasm"))]
#[path = "bridge.io.rs"]
mod io;
#[cfg(not(target_family = "wasm"))]
pub use io::*;
