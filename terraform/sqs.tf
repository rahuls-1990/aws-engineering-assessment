# Dead Letter Queues for Lambda functions

resource "aws_sqs_queue" "starter_lambda_dlq" {
  name                      = "starter-lambda-dlq"
  message_retention_seconds = 1209600  # 14 days

  tags = {
    Environment = "demo"
    Owner       = "assessment"
    ManagedBy   = "Terraform"
  }
}

resource "aws_sqs_queue" "processor_lambda_dlq" {
  name                      = "processor-lambda-dlq"
  message_retention_seconds = 1209600  # 14 days

  tags = {
    Environment = "demo"
    Owner       = "assessment"
    ManagedBy   = "Terraform"
  }
}

# CloudWatch Alarms for DLQ messages
resource "aws_cloudwatch_metric_alarm" "starter_lambda_dlq_messages" {
  alarm_name          = "starter-lambda-dlq-messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfVisibleMessages"
  namespace           = "AWS/SQS"
  period              = "60"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "This metric monitors messages in starter lambda DLQ"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]

  dimensions = {
    QueueName = aws_sqs_queue.starter_lambda_dlq.name
  }

  tags = {
    Environment = "demo"
    Owner       = "assessment"
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "processor_lambda_dlq_messages" {
  alarm_name          = "processor-lambda-dlq-messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfVisibleMessages"
  namespace           = "AWS/SQS"
  period              = "60"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "This metric monitors messages in processor lambda DLQ"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]

  dimensions = {
    QueueName = aws_sqs_queue.processor_lambda_dlq.name
  }

  tags = {
    Environment = "demo"
    Owner       = "assessment"
    ManagedBy   = "Terraform"
  }
}