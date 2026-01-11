variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token with appropriate permissions"
  sensitive   = true
}

variable "account_id" {
  type        = string
  description = "Cloudflare account ID"
}

variable "zone_id" {
  type        = string
  description = "Cloudflare zone ID for voulezvous.tv"
}

variable "r2_bucket_name" {
  type        = string
  default     = "vvtv-packs"
  description = "R2 bucket name for storing packs and proofs"
}

variable "kv_namespaces" {
  type = map(string)
  default = {
    "vvtv-config" = "v1"
  }
  description = "KV namespaces to create"
}

variable "d1_db_name" {
  type        = string
  default     = "vvtv_db"
  description = "D1 database name for metadata projection"
}

variable "worker_name" {
  type        = string
  default     = "vvtv-api"
  description = "Worker name for API"
}

variable "routes" {
  type        = list(string)
  default     = []
  description = "Worker routes (e.g., ['api.voulezvous.tv/*'])"
}

variable "queue_names" {
  type        = list(string)
  default     = ["vvtv-ingest", "vvtv-process"]
  description = "Cloudflare Queues to create"
}
