# Makefile for VVTV Infrastructure
# Solo-friendly: one command at a time

.PHONY: help cf-init cf-plan cf-apply cf-destroy lab-init lab-plan lab-apply lab-destroy all clean

# Colors
GREEN  := $(shell tput setaf 2)
YELLOW := $(shell tput setaf 3)
RED    := $(shell tput setaf 1)
RESET  := $(shell tput sgr0)

# Directories
CF_DIR  = infra/cloudflare
LAB_DIR = infra/lab

# Default target
help:
	@echo "$(GREEN)VVTV Infrastructure$(RESET)"
	@echo ""
	@echo "$(YELLOW)Cloudflare:$(RESET)"
	@echo "  make cf-init      - Initialize Cloudflare Terraform"
	@echo "  make cf-plan      - Plan Cloudflare changes"
	@echo "  make cf-apply     - Apply Cloudflare infrastructure"
	@echo "  make cf-destroy   - Destroy Cloudflare infrastructure"
	@echo ""
	@echo "$(YELLOW)LAB:$(RESET)"
	@echo "  make lab-init     - Initialize LAB Terraform"
	@echo "  make lab-plan     - Plan LAB changes"
	@echo "  make lab-apply    - Apply LAB infrastructure"
	@echo "  make lab-destroy  - Destroy LAB infrastructure"
	@echo ""
	@echo "$(YELLOW)Other:$(RESET)"
	@echo "  make all          - Apply both Cloudflare and LAB"
	@echo "  make clean        - Clean Terraform artifacts"

# ============================================
# Cloudflare targets
# ============================================
cf-init:
	@echo "$(GREEN)Initializing Cloudflare Terraform...$(RESET)"
	cd $(CF_DIR) && terraform init

cf-plan:
	@echo "$(GREEN)Planning Cloudflare changes...$(RESET)"
	cd $(CF_DIR) && terraform plan -var-file=envs/prod.tfvars

cf-apply:
	@echo "$(GREEN)Applying Cloudflare infrastructure...$(RESET)"
	cd $(CF_DIR) && terraform apply -var-file=envs/prod.tfvars

cf-destroy:
	@echo "$(RED)Destroying Cloudflare infrastructure...$(RESET)"
	@echo "$(YELLOW)This will DELETE resources!$(RESET)"
	@read -p "Are you sure? [y/N] " confirm && [ "$$confirm" = "y" ]
	cd $(CF_DIR) && terraform destroy -var-file=envs/prod.tfvars

# ============================================
# LAB targets
# ============================================
lab-init:
	@echo "$(GREEN)Initializing LAB Terraform...$(RESET)"
	cd $(LAB_DIR) && terraform init

lab-plan:
	@echo "$(GREEN)Planning LAB changes...$(RESET)"
	cd $(LAB_DIR) && terraform plan -var-file=vars/lab512.tfvars

lab-apply:
	@echo "$(GREEN)Applying LAB infrastructure...$(RESET)"
	cd $(LAB_DIR) && terraform apply -var-file=vars/lab512.tfvars

lab-destroy:
	@echo "$(RED)Destroying LAB infrastructure...$(RESET)"
	@echo "$(YELLOW)This will remove local configurations!$(RESET)"
	@read -p "Are you sure? [y/N] " confirm && [ "$$confirm" = "y" ]
	cd $(LAB_DIR) && terraform destroy -var-file=vars/lab512.tfvars

# ============================================
# Combined targets
# ============================================
all: cf-apply lab-apply
	@echo "$(GREEN)✅ All infrastructure deployed!$(RESET)"

clean:
	@echo "$(YELLOW)Cleaning Terraform artifacts...$(RESET)"
	rm -rf $(CF_DIR)/.terraform $(CF_DIR)/.terraform.lock.hcl
	rm -rf $(LAB_DIR)/.terraform $(LAB_DIR)/.terraform.lock.hcl
	rm -rf $(LAB_DIR)/render
	@echo "$(GREEN)✅ Clean complete$(RESET)"
