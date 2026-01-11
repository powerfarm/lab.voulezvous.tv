# LAB512 Configuration (Mac mini M2 Pro, 32GB)

lab_hostname  = "LAB512"
lab_user      = "ubl-ops"
enable_minio  = false

# Ollama models to seed
ollama_models = [
  "phi3:mini",
  "llama3.1:8b",
  "gemma2:9b"
]

# R2 Configuration (get from Cloudflare outputs)
r2_endpoint   = "https://<account-id>.r2.cloudflarestorage.com"
r2_bucket     = "vvtv-packs-prod"
r2_access_key = "REDACTED"  # Set via env: TF_VAR_r2_access_key
r2_secret_key = "REDACTED"  # Set via env: TF_VAR_r2_secret_key

# Worker URL (from Cloudflare outputs)
worker_url = "https://vvtv-api.voulezvous-tv.workers.dev"

# Optional: External LLM providers
openai_api_key    = ""  # Set via env if needed
anthropic_api_key = ""  # Set via env if needed
