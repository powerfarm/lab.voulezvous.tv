# Terraform Modules
# Placeholder for modular Cloudflare resources

This directory will contain reusable Terraform modules for:

- **cloudflare/**
  - `r2_bucket/` - R2 storage buckets
  - `d1_database/` - D1 SQL databases
  - `kv_namespace/` - KV namespaces
  - `queues/` - Cloudflare Queues
  - `worker_api/` - Worker deployments
  - `dns/` - DNS records
  - `tunnel/` - Cloudflare Tunnel config

- **lab/**
  - `secrets_env/` - Secret management
  - `ollama_pool/` - Ollama LLM pool setup
  - `minio_local/` - Local MinIO deployment
  - `runner_job/` - Job runner configuration

Each module will have:
- `main.tf` - Resources
- `variables.tf` - Inputs
- `outputs.tf` - Outputs
- `README.md` - Documentation

To be implemented as needed.
