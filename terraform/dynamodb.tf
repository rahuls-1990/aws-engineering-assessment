resource "aws_dynamodb_table" "file_uploads" {
  name         = "file-uploads"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Filename"
  range_key    = "UploadTimestamp"

  attribute {
    name = "Filename"
    type = "S"
  }

  attribute {
    name = "UploadTimestamp"
    type = "S"
  }

  table_class = "STANDARD"

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Environment = "demo"
    Owner       = "assessment"
    ManagedBy   = "Terraform"
  }
}
