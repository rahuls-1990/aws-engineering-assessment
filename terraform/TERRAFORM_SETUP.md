# 🏗️ Terraform Setup Guide

## Overview

This Terraform configuration uses a remote state backend for production-ready infrastructure management. The setup includes:

- **Remote State**: S3 bucket with versioning and encryption
- **State Locking**: DynamoDB table to prevent concurrent modifications
- **Environment Separation**: Dev, staging, and production configurations
- **Automated Scripts**: Easy deployment and backend setup

## 🚀 Quick Start

### 1. Prerequisites

```bash
# Install required tools
- AWS CLI configured with appropriate permissions
- Terraform >= 1.5.0
- Bash shell (for scripts)

# Verify AWS access
aws sts get-caller-identity
```

### 2. First-Time Setup (One-time only)

```bash
# 1. Update bucket name in backend-setup/terraform.tfvars
# Make it globally unique (e.g., yourcompany-terraform-state-dev)

# 2. Create the backend infrastructure
./scripts/setup-backend.sh

# 3. Update the bucket name in versions.tf to match
# 4. Initialize main Terraform with remote backend
terraform init
```

### 3. Deploy to Environments

```bash
# Plan deployment to dev
./scripts/deploy.sh dev plan

# Apply to dev environment
./scripts/deploy.sh dev apply

# Deploy to staging
./scripts/deploy.sh staging apply

# Deploy to production
./scripts/deploy.sh prod apply
```

## 📁 Directory Structure

```
terraform/
├── backend-setup/          # One-time backend infrastructure setup
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
├── environments/            # Environment-specific configurations
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
├── scripts/                 # Deployment automation
│   ├── setup-backend.sh
│   └── deploy.sh
├── *.tf                     # Main Terraform configuration
└── TERRAFORM_SETUP.md       # This file
```

## 🔧 Configuration Files

### Environment Variables

Each environment has its own `.tfvars` file with specific settings:

- **dev.tfvars**: Development environment (lower resources, shorter retention)
- **staging.tfvars**: Staging environment (production-like settings)
- **prod.tfvars**: Production environment (optimized for performance and reliability)

### Backend Configuration

The remote state backend provides:

- **State Storage**: S3 bucket with versioning and encryption
- **State Locking**: DynamoDB table prevents concurrent modifications
- **Team Collaboration**: Multiple developers can work safely
- **State History**: Version control for infrastructure changes

## 🛡️ Security Features

- **Encryption**: All state files encrypted at rest
- **Access Control**: IAM policies restrict backend access
- **Versioning**: State file history for rollback capability
- **Locking**: Prevents concurrent state modifications

## 📋 Common Commands

```bash
# Initialize Terraform (first time or after backend changes)
terraform init

# Plan changes for specific environment
terraform plan -var-file="environments/dev.tfvars"

# Apply changes
terraform apply -var-file="environments/dev.tfvars"

# Check current state
terraform show

# List workspaces
terraform workspace list

# Switch workspace
terraform workspace select staging

# Import existing resources
terraform import aws_s3_bucket.example bucket-name

# Format code
terraform fmt -recursive

# Validate configuration
terraform validate
```

## 🔍 Troubleshooting

### Backend Issues

```bash
# If backend initialization fails
terraform init -reconfigure

# If state is locked
terraform force-unlock LOCK_ID

# If you need to migrate state
terraform init -migrate-state
```

### Environment Issues

```bash
# Check current workspace
terraform workspace show

# Create new workspace
terraform workspace new production

# Delete workspace (must be empty)
terraform workspace delete old-environment
```

### State Issues

```bash
# Refresh state from real infrastructure
terraform refresh -var-file="environments/dev.tfvars"

# Show state
terraform state list
terraform state show aws_s3_bucket.uploads
```

## 🚨 Important Notes

1. **Never commit state files** - They're stored remotely now
2. **Always use environment-specific tfvars** - Prevents configuration drift
3. **Test in dev first** - Always validate changes in development
4. **Use workspaces for isolation** - Each environment gets its own state
5. **Backup is automatic** - S3 versioning provides state history

## 🔗 Next Steps

1. Set up CI/CD pipeline for automated deployments
2. Add Terraform validation tests
3. Implement policy as code with Sentinel or OPA
4. Add cost estimation with Infracost
5. Set up monitoring for Terraform operations

## 📞 Support

For issues or questions:
1. Check this documentation
2. Review Terraform logs
3. Consult team lead or DevOps engineer
4. Create issue in project repository