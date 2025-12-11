# Terraform Makefile for common operations
# Usage: make <target> ENV=<environment>

.PHONY: help init plan apply destroy fmt validate lint clean setup-backend

# Default environment
ENV ?= dev

# Colors for output
RED    := \033[31m
GREEN  := \033[32m
YELLOW := \033[33m
BLUE   := \033[34m
RESET  := \033[0m

help: ## Show this help message
	@echo "$(BLUE)Terraform Management Commands$(RESET)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Usage Examples:$(RESET)"
	@echo "  make plan ENV=dev     # Plan for development"
	@echo "  make apply ENV=prod   # Apply to production"
	@echo "  make fmt              # Format all files"

setup-backend: ## Set up Terraform remote state backend (one-time)
	@echo "$(BLUE)Setting up Terraform backend...$(RESET)"
	@./scripts/setup-backend.sh

init: ## Initialize Terraform
	@echo "$(BLUE)Initializing Terraform for $(ENV) environment...$(RESET)"
	@terraform init
	@terraform workspace select $(ENV) 2>/dev/null || terraform workspace new $(ENV)

fmt: ## Format Terraform files
	@echo "$(BLUE)Formatting Terraform files...$(RESET)"
	@terraform fmt -recursive

validate: fmt ## Validate Terraform configuration
	@echo "$(BLUE)Validating Terraform configuration...$(RESET)"
	@terraform validate

lint: validate ## Run linting checks
	@echo "$(BLUE)Running Terraform linting...$(RESET)"
	@if command -v tflint >/dev/null 2>&1; then \
		tflint --recursive; \
	else \
		echo "$(YELLOW)TFLint not installed. Install with: brew install tflint$(RESET)"; \
	fi

security-scan: ## Run security scanning
	@echo "$(BLUE)Running security scan...$(RESET)"
	@if command -v checkov >/dev/null 2>&1; then \
		checkov -d . --framework terraform; \
	else \
		echo "$(YELLOW)Checkov not installed. Install with: pip install checkov$(RESET)"; \
	fi

plan: init validate ## Plan Terraform changes
	@echo "$(BLUE)Planning Terraform changes for $(ENV) environment...$(RESET)"
	@terraform plan -var-file="environments/$(ENV).tfvars" -out="$(ENV).tfplan"

apply: init ## Apply Terraform changes
	@echo "$(BLUE)Applying Terraform changes for $(ENV) environment...$(RESET)"
	@if [ -f "$(ENV).tfplan" ]; then \
		terraform apply "$(ENV).tfplan"; \
		rm -f "$(ENV).tfplan"; \
	else \
		terraform apply -var-file="environments/$(ENV).tfvars"; \
	fi

destroy: init ## Destroy Terraform resources
	@echo "$(RED)WARNING: This will destroy all resources in $(ENV) environment!$(RESET)"
	@read -p "Are you sure? Type 'yes' to continue: " confirm && [ "$$confirm" = "yes" ]
	@terraform destroy -var-file="environments/$(ENV).tfvars"

output: ## Show Terraform outputs
	@echo "$(BLUE)Terraform outputs for $(ENV) environment:$(RESET)"
	@terraform output

state-list: ## List resources in Terraform state
	@echo "$(BLUE)Resources in $(ENV) state:$(RESET)"
	@terraform state list

refresh: init ## Refresh Terraform state
	@echo "$(BLUE)Refreshing Terraform state for $(ENV) environment...$(RESET)"
	@terraform refresh -var-file="environments/$(ENV).tfvars"

clean: ## Clean temporary files
	@echo "$(BLUE)Cleaning temporary files...$(RESET)"
	@rm -f *.tfplan
	@rm -f crash.log
	@rm -f crash.*.log
	@find . -name "*.backup" -delete
	@find . -name "*.tmp" -delete

docs: ## Generate documentation
	@echo "$(BLUE)Generating Terraform documentation...$(RESET)"
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs markdown table --output-file README.md .; \
	else \
		echo "$(YELLOW)terraform-docs not installed. Install with: brew install terraform-docs$(RESET)"; \
	fi

cost: ## Estimate costs (requires infracost)
	@echo "$(BLUE)Estimating costs for $(ENV) environment...$(RESET)"
	@if command -v infracost >/dev/null 2>&1; then \
		infracost breakdown --path . --terraform-var-file="environments/$(ENV).tfvars"; \
	else \
		echo "$(YELLOW)Infracost not installed. Install from: https://www.infracost.io/docs/$(RESET)"; \
	fi

workspace-list: ## List Terraform workspaces
	@echo "$(BLUE)Terraform workspaces:$(RESET)"
	@terraform workspace list

workspace-show: ## Show current workspace
	@echo "$(BLUE)Current workspace:$(RESET)"
	@terraform workspace show

# Development shortcuts
dev-plan: ENV=dev
dev-plan: plan ## Plan for development environment

dev-apply: ENV=dev
dev-apply: apply ## Apply to development environment

staging-plan: ENV=staging
staging-plan: plan ## Plan for staging environment

staging-apply: ENV=staging
staging-apply: apply ## Apply to staging environment

prod-plan: ENV=prod
prod-plan: plan ## Plan for production environment

prod-apply: ENV=prod
prod-apply: apply ## Apply to production environment

# Quality checks
check: fmt validate lint security-scan ## Run all quality checks

# Full deployment workflow
deploy: check plan apply ## Full deployment: check, plan, and apply

# Emergency commands
force-unlock: ## Force unlock Terraform state (use with caution)
	@echo "$(RED)Force unlocking Terraform state...$(RESET)"
	@read -p "Enter lock ID: " lock_id && terraform force-unlock $$lock_id

# Install development tools
install-tools: ## Install recommended development tools
	@echo "$(BLUE)Installing development tools...$(RESET)"
	@echo "Installing pre-commit..."
	@pip install pre-commit
	@pre-commit install
	@echo "$(GREEN)Tools installed! Consider also installing:$(RESET)"
	@echo "  - tflint: brew install tflint"
	@echo "  - checkov: pip install checkov"
	@echo "  - terraform-docs: brew install terraform-docs"
	@echo "  - infracost: https://www.infracost.io/docs/"