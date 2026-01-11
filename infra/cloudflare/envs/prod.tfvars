# Cloudflare Production Environment
# Update values before applying

cloudflare_api_token = "REDACTED"  # Set via env: TF_VAR_cloudflare_api_token
account_id           = "your-account-id-here"
zone_id              = "your-zone-id-here"

# Resources
r2_bucket_name = "vvtv-packs-prod"
worker_name    = "vvtv-api"
d1_db_name     = "vvtv_db_prod"

# Routing
routes = [
  "api.voulezvous.tv/*"
]

# KV Namespaces
kv_namespaces = {
  "vvtv-config" = "v1"
  "vvtv-cache"  = "v1"
}

# Queues
queue_names = [
  "vvtv-ingest",
  "vvtv-process",
  "vvtv-index"
]
