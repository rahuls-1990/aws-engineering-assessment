# Variables for Terraform backend setup

variable "region" {
  description = "AWS region for the backend resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.state_bucket_name))
    error_message = "Bucket name must be lowercase, start and end with alphanumeric characters, and can contain hyphens."
  }
}

variable "state_lock_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  type        = string
  default     = "terraform-state-locks"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]+$", var.state_lock_table_name))
    error_message = "Table name must contain only alphanumeric characters, hyphens, periods, and underscores."
  }
}