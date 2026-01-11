# ============================================
# R2 Storage
# ============================================
module "r2" {
  source     = "../modules/cloudflare/r2_bucket"
  account_id = var.account_id
  name       = var.r2_bucket_name
}

# ============================================
# KV Namespaces
# ============================================
module "kv" {
  source     = "../modules/cloudflare/kv_namespace"
  account_id = var.account_id
  namespaces = var.kv_namespaces
}

# ============================================
# D1 Database (SQL projection)
# ============================================
module "d1" {
  source     = "../modules/cloudflare/d1_database"
  account_id = var.account_id
  name       = var.d1_db_name
}

# ============================================
# Cloudflare Queues
# ============================================
module "queues" {
  source      = "../modules/cloudflare/queues"
  account_id  = var.account_id
  queue_names = var.queue_names
}

# ============================================
# Worker API
# ============================================
module "worker_api" {
  source     = "../modules/cloudflare/worker_api"
  account_id = var.account_id
  name       = var.worker_name
  routes     = var.routes
  
  bindings = {
    R2_PACKS = {
      type  = "r2_bucket"
      value = module.r2.bucket_name
    }
    D1_DB = {
      type  = "d1"
      value = module.d1.database_id
    }
    KV_CONFIG = {
      type  = "kv_namespace"
      value = module.kv.namespace_ids["vvtv-config"]
    }
    QUEUE_INGEST = {
      type  = "queue"
      value = module.queues.queue_ids["vvtv-ingest"]
    }
  }
}

# ============================================
# DNS (optional)
# ============================================
module "dns" {
  source  = "../modules/cloudflare/dns"
  zone_id = var.zone_id
  records = [
    # Example:
    # {
    #   name    = "api"
    #   type    = "CNAME"
    #   value   = module.worker_api.subdomain
    #   proxied = true
    # }
  ]
}
