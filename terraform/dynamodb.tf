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

  # Required for localstack stability
  table_class = "STANDARD"

  # Disable encryption — localstack v1.3.1 has a bug here
  server_side_encryption {
    enabled = false
  }
}
