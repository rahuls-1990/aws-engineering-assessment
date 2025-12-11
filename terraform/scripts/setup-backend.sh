#!/bin/bash

# Script to set up Terraform remote state backend
# Run this ONCE before using the main Terraform configuration

set -e

echo "🏗️  Setting up Terraform remote state backend..."

# Check if AWS CLI is configured
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

# Navigate to backend setup directory
cd "$(dirname "$0")/../backend-setup"

# Initialize and apply backend setup
echo "📦 Initializing backend setup..."
terraform init

echo "📋 Planning backend infrastructure..."
terraform plan

echo "🚀 Creating backend infrastructure..."
read -p "Do you want to create the backend infrastructure? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    terraform apply -auto-approve
    
    echo "✅ Backend infrastructure created successfully!"
    echo ""
    echo "📝 Next steps:"
    echo "1. Update the bucket name in terraform/versions.tf"
    echo "2. Run 'terraform init' in the main terraform directory"
    echo "3. Your state will be migrated to the remote backend"
    echo ""
    
    # Show the backend configuration
    echo "🔧 Backend configuration:"
    terraform output backend_config
else
    echo "❌ Backend setup cancelled."
    exit 1
fi