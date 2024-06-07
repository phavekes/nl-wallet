use std::sync::Arc;

use axum::{
    extract::{FromRequest, Path, Query, State},
    response::{IntoResponse, Response},
    routing::{get, on, post, MethodFilter},
    Form, Json, RequestExt, Router,
};
use http::{header, HeaderMap, HeaderValue, Method, Request, StatusCode};
use serde::{Deserialize, Serialize};
use tower_http::cors::{Any, CorsLayer};
use tracing::{info, warn};
use url::Url;

use nl_wallet_mdoc::{
    server_state::{SessionStore, SessionToken},
    verifier::{DisclosedAttributes, ItemsRequests, ReturnUrlTemplate, SessionType},
};
use openid4vc::{
    openid4vp::{VpResponse, WalletRequest},
    verifier::{
        DisclosureData, GetRequestErrorCode, PostAuthResponseErrorCode, StatusResponse, VerificationErrorCode,
        Verifier, VerifierUrlParameters, WalletAuthResponse,
    },
};
use wallet_common::{config::wallet_config::BaseUrl, generator::TimeGenerator};

use crate::{errors::ErrorResponse, settings::Settings};

struct ApplicationState<S> {
    verifier: Verifier<S>,
    internal_url: BaseUrl,
    public_url: BaseUrl,
    universal_link_base_url: BaseUrl,
}

pub fn create_routers<S>(settings: Settings, sessions: S) -> anyhow::Result<(Router, Router)>
where
    S: SessionStore<DisclosureData> + Send + Sync + 'static,
{
    let application_state = Arc::new(ApplicationState {
        verifier: Verifier::new(
            settings.verifier.usecases.try_into()?,
            sessions,
            settings
                .verifier
                .trust_anchors
                .into_iter()
                .map(|ta| ta.owned_trust_anchor)
                .collect::<Vec<_>>(),
            (&settings.verifier.ephemeral_id_secret).into(),
        ),
        internal_url: settings.internal_url,
        public_url: settings.public_url,
        universal_link_base_url: settings.universal_link_base_url,
    });

    // RFC 9101 defines just `GET` for the `request_uri` endpoint, but OpenID4VP extends that with `POST`.
    let wallet_router = Router::new()
        .route(
            "/:session_token/request_uri",
            on(MethodFilter::GET | MethodFilter::POST, retrieve_request::<S>),
        )
        .route("/:session_token/response_uri", post(post_response::<S>))
        .route(
            "/:session_token/status",
            get(status::<S>)
                // to be able to request the status from a browser, the cors headers should be set
                // but only on this endpoint
                .layer(CorsLayer::new().allow_methods([Method::GET]).allow_origin(Any)),
        )
        .with_state(application_state.clone());

    let requester_router = Router::new()
        .route("/", post(start::<S>))
        .route("/:session_token/disclosed_attributes", get(disclosed_attributes::<S>))
        .with_state(application_state);

    Ok((wallet_router, requester_router))
}

async fn retrieve_request<S>(
    State(state): State<Arc<ApplicationState<S>>>,
    Path(session_token): Path<SessionToken>,
    Query(url_params): Query<VerifierUrlParameters>,
    wallet_request: Option<Form<WalletRequest>>,
) -> Result<(HeaderMap, String), ErrorResponse<GetRequestErrorCode>>
where
    S: SessionStore<DisclosureData>,
{
    info!("process received message");

    let response = state
        .verifier
        .process_get_request(
            &session_token,
            &state.public_url.join_base_url("disclosure"),
            url_params,
            wallet_request.and_then(|r| r.0.wallet_nonce),
        )
        .await
        .map_err(|e| {
            warn!("processing message failed, returning error");
            ErrorResponse(e.into())
        })?;

    info!("message processed successfully, returning response");

    let headers = HeaderMap::from_iter([(
        header::CONTENT_TYPE,
        HeaderValue::from_str("application/oauth-authz-req+jwt").unwrap(),
    )]);
    Ok((headers, response.0))
}

async fn post_response<S>(
    State(state): State<Arc<ApplicationState<S>>>,
    Path(session_token): Path<SessionToken>,
    JsonOrForm(wallet_response): JsonOrForm<WalletAuthResponse>,
) -> Result<Json<VpResponse>, ErrorResponse<PostAuthResponseErrorCode>>
where
    S: SessionStore<DisclosureData>,
{
    info!("process received message");

    let response = state
        .verifier
        .process_authorization_response(&session_token, wallet_response, &TimeGenerator)
        .await
        .map_err(|e| {
            warn!("processing message failed, returning error");
            ErrorResponse(e.into())
        })?;

    info!("message processed successfully, returning response");

    Ok(Json(response))
}

#[derive(Debug, Serialize, Deserialize)]
pub struct StatusParams {
    pub session_type: SessionType,
}

async fn status<S>(
    State(state): State<Arc<ApplicationState<S>>>,
    Path(session_token): Path<SessionToken>,
    Query(params): Query<StatusParams>,
) -> Result<Json<StatusResponse>, ErrorResponse<VerificationErrorCode>>
where
    S: SessionStore<DisclosureData> + Send + Sync + 'static,
{
    let response = state
        .verifier
        .status_response(
            &session_token,
            params.session_type,
            &state.universal_link_base_url.join_base_url("disclosure"),
            &state.public_url.join_base_url("disclosure"),
            &TimeGenerator,
        )
        .await
        .map_err(|e| ErrorResponse(e.into()))?;

    Ok(Json(response))
}

#[derive(Debug, Serialize, Deserialize)]
pub struct StartDisclosureRequest {
    pub usecase: String,
    pub items_requests: ItemsRequests,
    pub return_url_template: Option<ReturnUrlTemplate>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct StartDisclosureResponse {
    pub status_url: Url,
    pub disclosed_attributes_url: Url,
}

async fn start<S>(
    State(state): State<Arc<ApplicationState<S>>>,
    Json(start_request): Json<StartDisclosureRequest>,
) -> Result<Json<StartDisclosureResponse>, ErrorResponse<VerificationErrorCode>>
where
    S: SessionStore<DisclosureData>,
{
    let session_token = state
        .verifier
        .new_session(
            start_request.items_requests,
            start_request.usecase,
            start_request.return_url_template,
        )
        .await
        .map_err(|e| ErrorResponse(e.into()))?;

    let status_url = state.public_url.join(&format!("disclosure/{session_token}/status"));
    let disclosed_attributes_url = state
        .internal_url
        .join(&format!("disclosure/sessions/{session_token}/disclosed_attributes"));

    Ok(Json(StartDisclosureResponse {
        status_url,
        disclosed_attributes_url,
    }))
}

#[derive(Debug, Serialize, Deserialize)]
pub struct DisclosedAttributesParams {
    pub nonce: Option<String>,
}

async fn disclosed_attributes<S>(
    State(state): State<Arc<ApplicationState<S>>>,
    Path(session_token): Path<SessionToken>,
    Query(params): Query<DisclosedAttributesParams>,
) -> Result<Json<DisclosedAttributes>, ErrorResponse<VerificationErrorCode>>
where
    S: SessionStore<DisclosureData>,
{
    let disclosed_attributes = state
        .verifier
        .disclosed_attributes(&session_token, params.nonce)
        .await
        .map_err(|e| ErrorResponse(e.into()))?;
    Ok(Json(disclosed_attributes))
}

/// An `axum` content type like [`Json`] for HTTP requests that deserializes from JSON or URL encoding,
/// based on the content type HTTP header.
/// Based on https://github.com/tokio-rs/axum/blob/main/examples/parse-body-based-on-content-type/src/main.rs.
struct JsonOrForm<T>(T);

#[axum::async_trait]
impl<S, T> FromRequest<S, axum::body::Body> for JsonOrForm<T>
where
    S: Send + Sync,
    T: 'static,
    Json<T>: FromRequest<(), axum::body::Body>,
    Form<T>: FromRequest<(), axum::body::Body>,
{
    type Rejection = Response;

    async fn from_request(req: Request<axum::body::Body>, _state: &S) -> Result<Self, Self::Rejection> {
        let content_type_header = req.headers().get(header::CONTENT_TYPE);
        let content_type = content_type_header.and_then(|value| value.to_str().ok());

        if let Some(content_type) = content_type {
            if content_type.starts_with("application/json") {
                let Json(payload) = req.extract().await.map_err(IntoResponse::into_response)?;
                return Ok(Self(payload));
            }

            if content_type.starts_with("application/x-www-form-urlencoded") {
                let Form(payload) = req.extract().await.map_err(IntoResponse::into_response)?;
                return Ok(Self(payload));
            }
        }

        Err(StatusCode::UNSUPPORTED_MEDIA_TYPE.into_response())
    }
}
