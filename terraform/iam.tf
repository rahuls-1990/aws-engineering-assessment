resource "aws_iam_role" "lambda_role" {
  name = "file-workflow-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "file-workflow-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:DescribeTable"
        ],
        Resource = aws_dynamodb_table.file_uploads.arn
      },
      {
        Effect = "Allow",
        Action = "sns:Publish",
        Resource = aws_sns_topic.security_alerts.arn    # FIXED
      }
    ]
  })
}
