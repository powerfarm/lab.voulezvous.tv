# Cloudflare Staging Environment

cloudflare_api_token = "REDACTED"  # Set via env: TF_VAR_cloudflare_api_token
account_id           = "your-account-id-here"
zone_id              = "your-zone-id-here"

# Resources
r2_bucket_name = "vvtv-packs-staging"
worker_name    = "vvtv-api-staging"
d1_db_name     = "vvtv_db_staging"

# Routing
routes = [
  "api-staging.voulezvous.tv/*"
]

# KV Namespaces
kv_namespaces = {
  "vvtv-config" = "staging"
}

# Queues
queue_names = [
  "vvtv-ingest-staging"
]
