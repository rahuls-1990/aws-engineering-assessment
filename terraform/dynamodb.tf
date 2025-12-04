resource "aws_dynamodb_table" "file_uploads" {
  name         = "file-uploads"
  hash_key     = "Filename"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "Filename"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }
}
