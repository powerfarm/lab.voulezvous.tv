output "env_file_path" {
  value       = local_file.env_lab.filename
  description = "Path to generated .env file"
}

output "launchd_ollama" {
  value       = local_file.launchd_ollama.filename
  description = "Path to Ollama launchd plist"
}

output "launchd_runner" {
  value       = local_file.launchd_runner.filename
  description = "Path to Runner launchd plist"
}

output "bootstrap_status" {
  value       = "Complete - Check /opt/vvtv/logs for details"
  description = "Bootstrap status"
  depends_on  = [null_resource.lab_bootstrap]
}
