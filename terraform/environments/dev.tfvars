# Development environment configuration
region              = "us-east-1"
alert_email         = "dev-alerts@yourcompany.com"
uploads_bucket_name = "yourcompany-file-processor-uploads-dev"

# Development-specific settings
log_retention_days         = 3
starter_lambda_timeout     = 10
processor_lambda_timeout   = 30
processor_lambda_memory    = 256

# Environment tag
environment = "dev"