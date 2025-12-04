resource "aws_s3_bucket" "uploads" {
  bucket        = "secure-bucket-upload"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "uploads_sse" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "uploads_lifecycle" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    id     = "expire-after-90-days"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_notification" "upload_events" {
  bucket = aws_s3_bucket.uploads.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.file_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

