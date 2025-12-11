# Production environment configuration
region              = "us-east-1"
alert_email         = "prod-alerts@yourcompany.com"
uploads_bucket_name = "yourcompany-file-processor-uploads-prod"

# Production-specific settings
log_retention_days         = 30
starter_lambda_timeout     = 15
processor_lambda_timeout   = 60
processor_lambda_memory    = 1024

# Environment tag
environment = "prod"