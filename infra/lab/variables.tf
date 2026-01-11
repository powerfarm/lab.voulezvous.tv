variable "lab_hostname" {
  type        = string
  default     = "LAB512"
  description = "Lab machine hostname"
}

variable "lab_user" {
  type        = string
  default     = "ubl-ops"
  description = "Lab user that runs services"
}

variable "ollama_models" {
  type = list(string)
  default = [
    "phi3:mini",
    "llama3.1:8b",
    "gemma2:9b"
  ]
  description = "Ollama models to seed"
}

variable "enable_minio" {
  type        = bool
  default     = false
  description = "Enable local MinIO for R2 simulation"
}

# ============================================
# R2 Configuration (from Cloudflare)
# ============================================
variable "r2_access_key" {
  type        = string
  sensitive   = true
  description = "R2 access key"
}

variable "r2_secret_key" {
  type        = string
  sensitive   = true
  description = "R2 secret key"
}

variable "r2_endpoint" {
  type        = string
  description = "R2 endpoint URL"
}

variable "r2_bucket" {
  type        = string
  description = "R2 bucket name"
}

variable "worker_url" {
  type        = string
  description = "Cloudflare Worker API URL"
}

# ============================================
# Optional: External LLM providers
# ============================================
variable "openai_api_key" {
  type        = string
  default     = ""
  sensitive   = true
  description = "OpenAI API key (optional)"
}

variable "anthropic_api_key" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Anthropic API key (optional)"
}
