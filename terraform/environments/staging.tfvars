# Staging environment configuration
region              = "us-east-1"
alert_email         = "staging-alerts@yourcompany.com"
uploads_bucket_name = "yourcompany-file-processor-uploads-staging"

# Staging-specific settings (closer to production)
log_retention_days         = 7
starter_lambda_timeout     = 10
processor_lambda_timeout   = 30
processor_lambda_memory    = 512

# Environment tag
environment = "staging"