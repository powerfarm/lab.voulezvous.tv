output "worker_url" {
  value       = module.worker_api.url
  description = "Worker API endpoint"
}

output "r2_bucket" {
  value       = module.r2.bucket_name
  description = "R2 bucket name"
}

output "d1_database_id" {
  value       = module.d1.database_id
  description = "D1 database ID"
}

output "d1_name" {
  value       = var.d1_db_name
  description = "D1 database name"
}

output "kv_namespace_ids" {
  value       = module.kv.namespace_ids
  description = "KV namespace IDs"
}

output "queue_ids" {
  value       = module.queues.queue_ids
  description = "Queue IDs"
}
