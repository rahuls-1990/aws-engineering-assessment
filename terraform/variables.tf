variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "alert_email" {
  description = "Email address for receiving SNS security alerts"
  type        = string
}

variable "uploads_bucket_name" {
  description = "Name of the S3 bucket where files are uploaded"
  type        = string
  default     = "secure-bucket-upload"
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

variable "starter_lambda_timeout" {
  description = "Timeout in seconds for the starter Lambda"
  type        = number
  default     = 10
}

variable "processor_lambda_timeout" {
  description = "Timeout in seconds for the processor Lambda"
  type        = number
  default     = 30
}

variable "processor_lambda_memory" {
  description = "Memory size in MB for the processor Lambda"
  type        = number
  default     = 256
}
