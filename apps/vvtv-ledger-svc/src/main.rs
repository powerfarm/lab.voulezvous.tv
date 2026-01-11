use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::{IntoResponse, Response},
    routing::{get, post},
    Json, Router,
};
use metrics_exporter_prometheus::{Matcher, PrometheusBuilder, PrometheusHandle};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use tokio::net::TcpListener;
use tower_http::trace::TraceLayer;
use tracing::{info, warn};

mod ledger;
mod types;

use ledger::LedgerManager;
use types::*;

#[derive(Clone)]
struct AppState {
    ledger: Arc<LedgerManager>,
    metrics: PrometheusHandle,
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Initialize tracing
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "vvtv_ledger_svc=debug,info".into()),
        )
        .json()
        .init();

    info!("🚀 Starting VVTV Ledger Service...");

    // Setup metrics
    let metrics_handle = PrometheusBuilder::new()
        .set_buckets_for_metric(
            Matcher::Full("ledger_append_duration_seconds".to_string()),
            &[0.001, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0],
        )?
        .install_recorder()?;

    // Initialize ledger manager
    let ledger_dir = std::env::var("VVTV_LEDGER_DIR")
        .unwrap_or_else(|_| "/var/lib/vvtv/ledger".to_string());
    let ledger = Arc::new(LedgerManager::new(&ledger_dir)?);

    let state = AppState {
        ledger,
        metrics: metrics_handle,
    };

    // Build router
    let app = Router::new()
        .route("/health", get(health))
        .route("/metrics", get(metrics_handler))
        .route("/facts", post(create_fact))
        .route("/facts/:cid", get(get_fact))
        .route("/facts/stream/:stream", get(list_facts))
        .layer(TraceLayer::new_for_http())
        .with_state(state);

    // Start server
    let addr = std::env::var("VVTV_LEDGER_BIND")
        .unwrap_or_else(|_| "0.0.0.0:8080".to_string());
    let listener = TcpListener::bind(&addr).await?;
    
    info!("✅ Listening on {}", addr);
    info!("📊 Metrics: http://{}/metrics", addr);
    info!("💚 Health: http://{}/health", addr);

    axum::serve(listener, app).await?;

    Ok(())
}

// ============================================
// Handlers
// ============================================

async fn health() -> impl IntoResponse {
    Json(serde_json::json!({
        "status": "healthy",
        "service": "vvtv-ledger-svc",
        "version": env!("CARGO_PKG_VERSION"),
    }))
}

async fn metrics_handler(State(state): State<AppState>) -> Response {
    state.metrics.render().into_response()
}

#[derive(Debug, Deserialize)]
struct CreateFactRequest {
    #[serde(flatten)]
    value: serde_json::Value,
}

#[derive(Debug, Serialize)]
struct CreateFactResponse {
    cid: String,
    stream: String,
    canonical: String,
}

async fn create_fact(
    State(state): State<AppState>,
    Json(payload): Json<CreateFactRequest>,
) -> Result<Json<CreateFactResponse>, AppError> {
    let start = std::time::Instant::now();

    // Canonicalize using json_atomic
    let canonical_bytes = json_atomic::canonicalize(&payload.value)
        .map_err(|e| AppError::Canonicalization(e.to_string()))?;
    
    let canonical_str = String::from_utf8(canonical_bytes.clone())
        .map_err(|e| AppError::Canonicalization(e.to_string()))?;

    // Compute CID (BLAKE3)
    let hash = blake3::hash(&canonical_bytes);
    let cid = hex::encode(hash.as_bytes());

    // Determine stream from fact type
    let stream = determine_stream(&payload.value)?;

    // Append to ledger
    state.ledger.append(&stream, &canonical_str, &cid).await?;

    // Record metrics
    let duration = start.elapsed();
    metrics::histogram!("ledger_append_duration_seconds", duration.as_secs_f64());
    metrics::counter!("facts_written_total", "stream" => stream.clone()).increment(1);

    info!(
        cid = %cid,
        stream = %stream,
        duration_ms = duration.as_millis(),
        "✅ Fact appended"
    );

    Ok(Json(CreateFactResponse {
        cid,
        stream,
        canonical: canonical_str,
    }))
}

async fn get_fact(
    State(state): State<AppState>,
    Path(cid): Path<String>,
) -> Result<Response, AppError> {
    let fact = state.ledger.get(&cid).await?;

    Ok((
        StatusCode::OK,
        [
            ("Content-Type", "application/json"),
            ("X-Content-CID", &cid),
            ("X-Content-Hash", &compute_hash(&fact)),
        ],
        fact,
    )
        .into_response())
}

async fn list_facts(
    State(state): State<AppState>,
    Path(stream): Path<String>,
) -> Result<Json<Vec<String>>, AppError> {
    let facts = state.ledger.list_stream(&stream).await?;
    Ok(Json(facts))
}

// ============================================
// Helpers
// ============================================

fn determine_stream(value: &serde_json::Value) -> Result<String, AppError> {
    let fact_type = value
        .get("type")
        .and_then(|v| v.as_str())
        .ok_or_else(|| AppError::MissingField("type".to_string()))?;

    let stream = match fact_type {
        // Plans
        "PlanCreated" | "PlanScheduledForDownload" | "PlanArchived" => "plans",
        
        // Assets
        "AssetCreated" | "AssetDownloadStarted" | "AssetDownloadCompleted" 
        | "AssetDownloadFailed" | "AssetReady" | "QCReport" => "assets",
        
        // Queue
        "QueueItemAdded" | "QueueItemPromoted" | "QueueItemRemoved" 
        | "CuratorDecision" => "queue",
        
        // Playout
        "PlayoutSegmentAppended" | "PlayoutRotated" | "PlayoutEmergencyLoop" 
        | "StreamEvent" => "playout",
        
        // Policy
        "PolicyPatched" | "PolicyRollback" | "AutopilotApplied" 
        | "AutopilotRollback" => "policy",
        
        _ => return Err(AppError::UnknownFactType(fact_type.to_string())),
    };

    Ok(stream.to_string())
}

fn compute_hash(data: &str) -> String {
    let hash = blake3::hash(data.as_bytes());
    hex::encode(hash.as_bytes())
}

// ============================================
// Error handling
// ============================================

#[derive(Debug, thiserror::Error)]
enum AppError {
    #[error("Canonicalization error: {0}")]
    Canonicalization(String),
    
    #[error("Ledger error: {0}")]
    Ledger(#[from] anyhow::Error),
    
    #[error("Missing required field: {0}")]
    MissingField(String),
    
    #[error("Unknown fact type: {0}")]
    UnknownFactType(String),
    
    #[error("Fact not found: {0}")]
    NotFound(String),
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let (status, message) = match self {
            AppError::NotFound(ref msg) => (StatusCode::NOT_FOUND, msg.clone()),
            AppError::UnknownFactType(ref msg) => (StatusCode::BAD_REQUEST, msg.clone()),
            AppError::MissingField(ref msg) => (StatusCode::BAD_REQUEST, format!("Missing field: {}", msg)),
            _ => (StatusCode::INTERNAL_SERVER_ERROR, self.to_string()),
        };

        warn!("Error: {}", self);
        metrics::counter!("ledger_errors_total", "error" => format!("{:?}", self)).increment(1);

        (
            status,
            Json(serde_json::json!({
                "error": message
            })),
        )
            .into_response()
    }
}
