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
  handler       = "processor_lambda.lambda_handler"
  runtime       = "python3.12"

  role                           = aws_iam_role.lambda_role.arn
  timeout                        = var.processor_lambda_timeout
  memory_size                    = var.processor_lambda_memory
  reserved_concurrent_executions = 5

  filename         = "${path.module}/lambda/function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/function.zip")

  environment {
    variables = {
      DDB_TABLE_NAME = aws_dynamodb_table.file_uploads.name
      SNS_TOPIC_ARN  = aws_sns_topic.security_alerts.arn
    }
  }

  dead_letter_config {
    target_arn = aws_sqs_queue.processor_lambda_dlq.arn
  }

  depends_on = [aws_cloudwatch_log_group.file_processor_logs]
}

resource "aws_cloudwatch_log_group" "starter_lambda_logs" {
  name              = "/aws/lambda/file-upload-starter"
  retention_in_days = var.log_retention_days
}

resource "aws_lambda_function" "starter_lambda" {
  function_name = "file-upload-starter"
  handler       = "starter_lambda.lambda_handler"
  runtime       = "python3.12"
  role          = aws_iam_role.starter_lambda_role.arn

  timeout                        = var.starter_lambda_timeout
  memory_size                    = 128
  reserved_concurrent_executions = 5

  filename         = "${path.module}/lambda/lambda_starter.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/lambda_starter.zip")

  environment {
    variables = {
      STATE_MACHINE_ARN = aws_sfn_state_machine.file_workflow.arn
    }
  }

  dead_letter_config {
    target_arn = aws_sqs_queue.starter_lambda_dlq.arn
  }

  depends_on = [
    aws_cloudwatch_log_group.starter_lambda_logs
  ]
}

resource "aws_lambda_permission" "allow_s3_to_starter" {
  statement_id  = "AllowS3InvokeStarter"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.starter_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.uploads.arn
}
