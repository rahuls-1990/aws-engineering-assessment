# 📁 Terraform Repository Guidelines

## ✅ **What SHOULD be in the Repository**

### **Core Terraform Files**
```
✅ *.tf files                    # All Terraform configuration
✅ *.tf.json files              # JSON-format Terraform config
✅ .terraform.lock.hcl          # Provider version locks (CRITICAL)
✅ versions.tf                  # Terraform and provider versions
✅ variables.tf                 # Variable definitions
✅ outputs.tf                   # Output definitions
✅ locals.tf                    # Local values
```

### **Environment Configuration**
```
✅ environments/*.tfvars        # Environment-specific configs
✅ environments/dev.tfvars      # Development settings
✅ environments/staging.tfvars  # Staging settings  
✅ environments/prod.tfvars     # Production settings
```

### **Documentation & Scripts**
```
✅ README.md                    # Project overview and setup
✅ TERRAFORM_SETUP.md          # Detailed setup instructions
✅ scripts/*.sh                # Deployment automation scripts
✅ docs/                       # Architecture and design docs
```

### **Configuration Files**
```
✅ .terraform-version          # Terraform version specification
✅ .tflint.hcl                # Terraform linting configuration
✅ .pre-commit-config.yaml    # Pre-commit hooks
✅ Makefile                   # Build automation (optional)
```

### **Testing & Validation**
```
✅ tests/                     # Terratest or other test files
✅ examples/                  # Usage examples
✅ .github/workflows/         # CI/CD pipeline definitions
```

## ❌ **What should NEVER be in the Repository**

### **State Files (Use Remote Backend)**
```
❌ terraform.tfstate          # Local state files
❌ terraform.tfstate.*        # State backups
❌ *.tfstate                  # Any state files
❌ .terraform/                # Terraform working directory
```

### **Sensitive Data**
```
❌ *.auto.tfvars             # Auto-loaded variable files
❌ terraform.tfvars          # Default variable file (often has secrets)
❌ *secret*.tfvars           # Files with secrets in name
❌ .env                      # Environment files
❌ *.pem, *.key, *.crt      # Certificates and keys
❌ aws-credentials           # AWS credential files
```

### **Temporary & Generated Files**
```
❌ *.tfplan                  # Terraform plan files
❌ crash.log                 # Terraform crash logs
❌ *.backup                  # Backup files
❌ .DS_Store                 # macOS system files
❌ Thumbs.db                 # Windows system files
```

## 🔒 **Security Best Practices**

### **1. Secrets Management**
```bash
# ✅ Good: Use environment variables
export TF_VAR_db_password="secret123"

# ✅ Good: Use AWS Secrets Manager
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/db/password"
}

# ❌ Bad: Hardcoded in tfvars
db_password = "secret123"  # NEVER DO THIS
```

### **2. Variable File Strategy**
```
✅ environments/dev.tfvars     # Non-sensitive environment config
✅ environments/prod.tfvars    # Non-sensitive production config
❌ secrets.tfvars              # Don't create files named with "secret"
❌ terraform.tfvars            # Often contains sensitive data
```

### **3. State File Security**
```bash
# ✅ Good: Remote backend with encryption
terraform {
  backend "s3" {
    bucket  = "terraform-state-bucket"
    encrypt = true
  }
}

# ❌ Bad: Local state files
# These contain sensitive data and should never be committed
```

## 📋 **Repository Structure Example**

```
project-root/
├── .gitignore                    ✅ Comprehensive ignore rules
├── README.md                     ✅ Project overview
├── terraform/
│   ├── .terraform.lock.hcl       ✅ Provider locks (COMMIT)
│   ├── versions.tf               ✅ Version constraints
│   ├── variables.tf              ✅ Variable definitions
│   ├── outputs.tf                ✅ Output definitions
│   ├── main.tf                   ✅ Main configuration
│   ├── iam.tf                    ✅ IAM resources
│   ├── s3.tf                     ✅ S3 resources
│   ├── lambda.tf                 ✅ Lambda resources
│   ├── TERRAFORM_SETUP.md        ✅ Setup documentation
│   ├── backend-setup/            ✅ Backend infrastructure
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── environments/             ✅ Environment configs
│   │   ├── dev.tfvars            ✅ Development settings
│   │   ├── staging.tfvars        ✅ Staging settings
│   │   └── prod.tfvars           ✅ Production settings
│   ├── scripts/                  ✅ Automation scripts
│   │   ├── setup-backend.sh
│   │   └── deploy.sh
│   ├── tests/                    ✅ Test files
│   └── docs/                     ✅ Documentation
├── .github/
│   └── workflows/                ✅ CI/CD pipelines
│       └── terraform.yml
└── .terraform-version            ✅ Version specification
```

## 🔍 **Pre-Commit Checklist**

Before committing Terraform code:

```bash
# 1. Format code
terraform fmt -recursive

# 2. Validate configuration
terraform validate

# 3. Check for secrets
git diff --cached | grep -i "password\|secret\|key"

# 4. Lint with TFLint (if configured)
tflint

# 5. Security scan with Checkov (if configured)
checkov -d .

# 6. Plan to verify changes
terraform plan -var-file="environments/dev.tfvars"
```

## 🚨 **Emergency: Secrets Accidentally Committed**

If you accidentally commit secrets:

```bash
# 1. Remove from current commit
git reset HEAD~1
git add .gitignore  # Add proper ignore rules
git commit -m "Add proper .gitignore"

# 2. If already pushed, you MUST:
# - Rotate all exposed credentials immediately
# - Consider the secrets compromised
# - Use git filter-branch or BFG to clean history
# - Force push (if safe) or create new repository

# 3. Prevent future issues
# - Set up pre-commit hooks
# - Use git-secrets or similar tools
# - Implement proper secrets management
```

## 🛠️ **Recommended Tools**

### **Code Quality**
- **terraform fmt**: Code formatting
- **terraform validate**: Configuration validation
- **TFLint**: Terraform linting
- **Checkov**: Security and compliance scanning
- **terraform-docs**: Documentation generation

### **Security**
- **git-secrets**: Prevent committing secrets
- **truffleHog**: Find secrets in git history
- **pre-commit**: Git hooks for validation

### **Testing**
- **Terratest**: Infrastructure testing framework
- **Kitchen-Terraform**: Test Kitchen for Terraform
- **Terraform Compliance**: Policy testing

## 📞 **Quick Reference**

```bash
# Check what's ignored
git status --ignored

# See what would be committed
git diff --cached --name-only

# Remove accidentally tracked files
git rm --cached filename
echo "filename" >> .gitignore

# Clean working directory
git clean -fd

# Check for large files
git ls-files | xargs ls -la | sort -k5 -rn | head
```

Remember: **When in doubt, don't commit it!** It's easier to add files later than to remove sensitive data from git history.