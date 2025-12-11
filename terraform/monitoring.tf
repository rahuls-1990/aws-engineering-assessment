# CloudWatch Alarms for monitoring Lambda functions and Step Functions

# Lambda Error Alarms
resource "aws_cloudwatch_metric_alarm" "starter_lambda_errors" {
  alarm_name          = "starter-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors starter lambda errors"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.starter_lambda.function_name
  }

  tags = {
    Environment = "demo"
    Owner       = "assessment"
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "processor_lambda_errors" {
  alarm_name          = "processor-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors processor lambda errors"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.file_processor.function_name
  }

  tags = {
    Environment = "demo"
    Owner       = "assessment"
    ManagedBy   = "Terraform"
  }
}

# Lambda Duration Alarms
resource "aws_cloudwatch_metric_alarm" "starter_lambda_duration" {
  alarm_name          = "starter-lambda-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Average"
  threshold           = "5000"  # 5 seconds
  alarm_description   = "This metric monitors starter lambda duration"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.starter_lambda.function_name
  }

  tags = {
    Environment = "demo"
    Owner       = "assessment"
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "processor_lambda_duration" {
  alarm_name          = "processor-lambda-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Average"
  threshold           = "20000"  # 20 seconds
  alarm_description   = "This metric monitors processor lambda duration"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.file_processor.function_name
  }

  tags = {
    Environment = "demo"
    Owner       = "assessment"
    ManagedBy   = "Terraform"
  }
}

# Step Functions Execution Failed Alarm
resource "aws_cloudwatch_metric_alarm" "step_function_failed" {
  alarm_name          = "step-function-execution-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ExecutionsFailed"
  namespace           = "AWS/States"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors step function execution failures"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]

  dimensions = {
    StateMachineArn = aws_sfn_state_machine.file_workflow.arn
  }

  tags = {
    Environment = "demo"
    Owner       = "assessment"
    ManagedBy   = "Terraform"
  }
}

# DynamoDB Throttling Alarm
resource "aws_cloudwatch_metric_alarm" "dynamodb_throttles" {
  alarm_name          = "dynamodb-throttles"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors DynamoDB throttling"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]

  dimensions = {
    TableName = aws_dynamodb_table.file_uploads.name
  }

  tags = {
    Environment = "demo"
    Owner       = "assessment"
    ManagedBy   = "Terraform"
  }
}