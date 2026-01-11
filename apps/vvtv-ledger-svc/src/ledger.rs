use anyhow::{Context, Result};
use std::collections::HashMap;
use std::path::{Path, PathBuf};
use tokio::fs::{self, OpenOptions};
use tokio::io::AsyncWriteExt;
use tokio::sync::RwLock;
use tracing::{debug, info};

/// Manages multiple NDJSON ledger streams
pub struct LedgerManager {
    base_dir: PathBuf,
    streams: RwLock<HashMap<String, StreamWriter>>,
}

struct StreamWriter {
    path: PathBuf,
}

impl LedgerManager {
    pub fn new(base_dir: impl AsRef<Path>) -> Result<Self> {
        let base_dir = base_dir.as_ref().to_path_buf();
        std::fs::create_dir_all(&base_dir)
            .context("Failed to create ledger directory")?;

        info!("📁 Ledger directory: {}", base_dir.display());

        Ok(Self {
            base_dir,
            streams: RwLock::new(HashMap::new()),
        })
    }

    /// Append a canonical fact to the appropriate stream
    pub async fn append(&self, stream: &str, canonical: &str, cid: &str) -> Result<()> {
        let path = self.base_dir.join(format!("{}.ndjson", stream));

        // Ensure stream exists
        {
            let mut streams = self.streams.write().await;
            if !streams.contains_key(stream) {
                streams.insert(
                    stream.to_string(),
                    StreamWriter { path: path.clone() },
                );
                debug!("📝 Created stream: {}", stream);
            }
        }

        // Append line
        let mut file = OpenOptions::new()
            .create(true)
            .append(true)
            .open(&path)
            .await
            .context("Failed to open ledger file")?;

        file.write_all(canonical.as_bytes()).await?;
        file.write_all(b"\n").await?;
        file.flush().await?;

        debug!(
            stream = %stream,
            cid = %cid,
            path = %path.display(),
            "✅ Appended to ledger"
        );

        Ok(())
    }

    /// Get a fact by CID (searches all streams)
    pub async fn get(&self, cid: &str) -> Result<String> {
        let streams = vec!["plans", "assets", "queue", "playout", "policy"];

        for stream in streams {
            let path = self.base_dir.join(format!("{}.ndjson", stream));
            if !path.exists() {
                continue;
            }

            let content = fs::read_to_string(&path).await?;
            for line in content.lines() {
                let computed_cid = compute_cid(line);
                if computed_cid == cid {
                    return Ok(line.to_string());
                }
            }
        }

        Err(anyhow::anyhow!("Fact not found: {}", cid))
    }

    /// List all facts in a stream
    pub async fn list_stream(&self, stream: &str) -> Result<Vec<String>> {
        let path = self.base_dir.join(format!("{}.ndjson", stream));
        
        if !path.exists() {
            return Ok(vec![]);
        }

        let content = fs::read_to_string(&path).await?;
        let facts: Vec<String> = content.lines().map(|s| s.to_string()).collect();

        Ok(facts)
    }

    /// Get stats for all streams
    pub async fn stats(&self) -> Result<HashMap<String, usize>> {
        let mut stats = HashMap::new();
        let streams = vec!["plans", "assets", "queue", "playout", "policy"];

        for stream in streams {
            let path = self.base_dir.join(format!("{}.ndjson", stream));
            if !path.exists() {
                stats.insert(stream.to_string(), 0);
                continue;
            }

            let content = fs::read_to_string(&path).await?;
            let count = content.lines().count();
            stats.insert(stream.to_string(), count);
        }

        Ok(stats)
    }
}

fn compute_cid(line: &str) -> String {
    let hash = blake3::hash(line.as_bytes());
    hex::encode(hash.as_bytes())
}
