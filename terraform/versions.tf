terraform {
  required_version = ">= 1.5.0"

  # Remote state backend configuration
  # Run the backend-setup first to create these resources
  backend "s3" {
    bucket         = "your-company-terraform-state-dev"  # Update this to match your bucket name
    key            = "file-processor/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
