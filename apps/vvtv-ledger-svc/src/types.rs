use serde::{Deserialize, Serialize};

// ============================================
// Fact Types (examples)
// ============================================

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type")]
pub enum Fact {
    // Plans
    PlanCreated(PlanCreated),
    PlanScheduledForDownload(PlanScheduledForDownload),
    
    // Assets
    AssetCreated(AssetCreated),
    AssetDownloadCompleted(AssetDownloadCompleted),
    QCReport(QCReport),
    
    // Queue
    QueueItemAdded(QueueItemAdded),
    CuratorDecision(CuratorDecision),
    
    // Playout
    PlayoutSegmentAppended(PlayoutSegmentAppended),
    StreamEvent(StreamEvent),
    
    // Policy
    PolicyPatched(PolicyPatched),
    AutopilotApplied(AutopilotApplied),
}

// ============================================
// Plan Facts
// ============================================

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlanCreated {
    pub timestamp: String,
    pub plan_id: String,
    pub source: String,
    pub url: String,
    pub title: Option<String>,
    pub duration_secs: Option<u32>,
    pub tags: Vec<String>,
    pub bucket: Option<String>,
    pub quality_hint: Option<String>,
    pub score: Option<f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlanScheduledForDownload {
    pub timestamp: String,
    pub plan_id: String,
    pub slot: String,
    pub scheduled_at: String,
    pub reason: String,
}

// ============================================
// Asset Facts
// ============================================

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AssetCreated {
    pub timestamp: String,
    pub asset_id: String,
    pub plan_id: String,
    pub source_url: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AssetDownloadCompleted {
    pub timestamp: String,
    pub asset_id: String,
    pub size_bytes: u64,
    pub codec: String,
    pub resolution: String,
    pub duration_secs: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct QCReport {
    pub timestamp: String,
    pub asset_id: String,
    pub pass: bool,
    pub vmaf: Option<f64>,
    pub ssim: Option<f64>,
    pub lufs: Option<f64>,
    pub resolution: String,
    pub reason: Option<String>,
}

// ============================================
// Queue Facts
// ============================================

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct QueueItemAdded {
    pub timestamp: String,
    pub queue_id: String,
    pub asset_id: String,
    pub slot: String,
    pub position: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CuratorDecision {
    pub timestamp: String,
    pub decision_type: String, // "Advice" | "Apply"
    pub signals: Vec<String>,
    pub suggestions: Vec<String>,
    pub confidence: f64,
    pub llm_action: Option<LLMAction>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LLMAction {
    pub provider: String,
    pub model: String,
    pub reason: String,
}

// ============================================
// Playout Facts
// ============================================

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlayoutSegmentAppended {
    pub timestamp: String,
    pub segment_id: String,
    pub asset_id: String,
    pub hls_path: String,
    pub duration_secs: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StreamEvent {
    pub timestamp: String,
    pub event_type: String, // "started" | "rotated" | "ended" | "emergency_loop"
    pub slot: String,
    pub buffer_secs: Option<f64>,
}

// ============================================
// Policy Facts
// ============================================

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PolicyPatched {
    pub timestamp: String,
    pub patch_id: String,
    pub changes: Vec<PolicyChange>,
    pub reason: String,
    pub approved_by: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PolicyChange {
    pub path: String,
    pub old_value: serde_json::Value,
    pub new_value: serde_json::Value,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AutopilotApplied {
    pub timestamp: String,
    pub autopilot_id: String,
    pub changes: Vec<PolicyChange>,
    pub kpis: serde_json::Value,
    pub canary_result: String, // "success" | "rollback"
}
