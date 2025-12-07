# CloudWatch log group for the Lambda function
resource "aws_cloudwatch_log_group" "file_processor_logs" {
  name              = "/aws/lambda/file-processor"
  retention_in_days = 3

  tags = {
    Environment = "demo"
    Owner       = "assessment"
    ManagedBy   = "Terraform"
  }
}

resource "aws_lambda_function" "file_processor" {
  function_name = "file-processor"
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"

  role = aws_iam_role.lambda_role.arn

  filename         = "${path.module}/lambda/function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/function.zip")

  environment {
    variables = {
      DDB_TABLE_NAME = aws_dynamodb_table.file_uploads.name
      SNS_TOPIC_ARN  = aws_sns_topic.security_alerts.arn
    }
  }

  # Ensure log group exists before Lambda executes
  depends_on = [
    aws_cloudwatch_log_group.file_processor_logs
  ]

  tags = {
    Environment = "demo"
    Owner       = "assessment"
    Purpose     = "S3 file processing"
    ManagedBy   = "Terraform"
  }
}

# Allow S3 to invoke this Lambda
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
