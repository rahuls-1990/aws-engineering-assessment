#!/bin/bash

# Deployment script for different environments
# Usage: ./deploy.sh [dev|staging|prod] [plan|apply|destroy]

set -e

ENVIRONMENT=${1:-dev}
ACTION=${2:-plan}

# Validate inputs
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    echo "❌ Invalid environment. Use: dev, staging, or prod"
    exit 1
fi

if [[ ! "$ACTION" =~ ^(plan|apply|destroy)$ ]]; then
    echo "❌ Invalid action. Use: plan, apply, or destroy"
    exit 1
fi

# Navigate to terraform directory
cd "$(dirname "$0")/.."

echo "🚀 Deploying to $ENVIRONMENT environment..."

# Check if backend is initialized
if [ ! -d ".terraform" ]; then
    echo "📦 Initializing Terraform..."
    terraform init
fi

# Set the workspace (optional, for multiple environments in same backend)
echo "🔧 Setting workspace to $ENVIRONMENT..."
terraform workspace select $ENVIRONMENT 2>/dev/null || terraform workspace new $ENVIRONMENT

# Run the specified action
case $ACTION in
    plan)
        echo "📋 Planning deployment for $ENVIRONMENT..."
        terraform plan -var-file="environments/${ENVIRONMENT}.tfvars"
        ;;
    apply)
        echo "🚀 Applying deployment for $ENVIRONMENT..."
        terraform apply -var-file="environments/${ENVIRONMENT}.tfvars"
        ;;
    destroy)
        echo "💥 Destroying resources in $ENVIRONMENT..."
        read -p "Are you sure you want to destroy $ENVIRONMENT? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            terraform destroy -var-file="environments/${ENVIRONMENT}.tfvars"
        else
            echo "❌ Destroy cancelled."
            exit 1
        fi
        ;;
esac

echo "✅ $ACTION completed for $ENVIRONMENT environment!"