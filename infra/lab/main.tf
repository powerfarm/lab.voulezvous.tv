# ============================================
# 1. Render .env for LAB services
# ============================================
resource "local_file" "env_lab" {
  filename = "${path.module}/render/.env.lab"
  content = templatefile("${path.module}/files/env.lab.tmpl", {
    R2_ENDPOINT       = var.r2_endpoint
    R2_BUCKET         = var.r2_bucket
    R2_ACCESS_KEY     = var.r2_access_key
    R2_SECRET_KEY     = var.r2_secret_key
    WORKER_URL        = var.worker_url
    OPENAI_API_KEY    = var.openai_api_key
    ANTHROPIC_API_KEY = var.anthropic_api_key
  })
  
  file_permission = "0600"
}

# ============================================
# 2. Launchd plists (Ollama + Runner)
# ============================================
resource "local_file" "launchd_ollama" {
  filename = "${path.module}/render/vvtv.ollama.plist"
  content = templatefile("${path.module}/files/launchd.ollama.plist.tmpl", {
    USER = var.lab_user
  })
  
  file_permission = "0644"
}

resource "local_file" "launchd_runner" {
  filename = "${path.module}/render/vvtv.runner.plist"
  content = templatefile("${path.module}/files/launchd.vvtv-runner.plist.tmpl", {
    USER = var.lab_user
  })
  
  file_permission = "0644"
}

# ============================================
# 3. Bootstrap LAB (install tools, seed models)
# ============================================
resource "null_resource" "lab_bootstrap" {
  triggers = {
    env_hash     = filesha256(local_file.env_lab.filename)
    models       = join(",", var.ollama_models)
    enable_minio = tostring(var.enable_minio)
  }
  
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOC
      set -e
      
      # Make scripts executable
      chmod +x ${path.module}/files/scripts/install_tools.sh
      chmod +x ${path.module}/files/scripts/seed_models_ollama.sh
      chmod +x ${path.module}/files/scripts/start_minio.sh
      chmod +x ${path.module}/files/scripts/smoke_r2.sh
      
      # Create directories
      sudo mkdir -p /opt/vvtv/config /opt/vvtv/logs /var/lib/vvtv/{ledger,packs,work,cache}
      
      # Copy configs
      sudo cp ${local_file.env_lab.filename} /opt/vvtv/config/.env
      sudo cp ${local_file.launchd_ollama.filename} /Library/LaunchDaemons/vvtv.ollama.plist
      sudo cp ${local_file.launchd_runner.filename} /Library/LaunchDaemons/vvtv.runner.plist
      
      # Set ownership
      sudo chown -R ${var.lab_user}:staff /opt/vvtv /var/lib/vvtv
      
      # Install tools (brew, ffmpeg, ollama, etc.)
      sudo -u ${var.lab_user} ${path.module}/files/scripts/install_tools.sh
      
      # Seed Ollama models
      ${path.module}/files/scripts/seed_models_ollama.sh ${join(" ", var.ollama_models)}
      
      # Optional: Start MinIO
      if [ "${var.enable_minio}" = "true" ]; then
        ${path.module}/files/scripts/start_minio.sh
      fi
      
      # Smoke test
      ${path.module}/files/scripts/smoke_r2.sh "${var.worker_url}"
      
      echo "✅ LAB bootstrap complete"
    EOC
  }
}
