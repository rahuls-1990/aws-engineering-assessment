resource "aws_lambda_function" "file_processor" {
  function_name = "file-processor"
  handler       = "handler.lambda_handler"
  runtime       = "python3.12" # updated from 3.9

  role = aws_iam_role.lambda_role.arn

  filename         = "${path.module}/lambda/function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/function.zip")

  environment {
    variables = {
      DDB_TABLE_NAME = aws_dynamodb_table.file_uploads.name
      SNS_TOPIC_ARN  = aws_sns_topic.security_alerts.arn
    }
  }

  tags = {
    Environment = "demo"
    Owner       = "assessment"
    Purpose     = "S3 file processing"
    ManagedBy   = "Terraform"
  }
}

# Allow S3 to invoke this Lambda when new objects are created
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.uploads.arn
}

output "lambda_arn" {
  value = aws_lambda_function.file_processor.arn
}

