# IAM role for Step Functions
resource "aws_iam_role" "stepfn_role" {
  name = "file-workflow-stepfn-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "states.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "stepfn_policy" {
  name = "file-workflow-stepfn-policy"
  role = aws_iam_role.stepfn_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["lambda:InvokeFunction"],
        Resource = aws_lambda_function.file_processor.arn
      },
      {
        Effect   = "Allow",
        Action   = ["sns:Publish"],
        Resource = aws_sns_topic.security_alerts.arn
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/stepfunctions/*"
      }
    ]
  })
}

# State machine definition
resource "aws_sfn_state_machine" "file_workflow" {
  name     = "file-upload-workflow"
  role_arn = aws_iam_role.stepfn_role.arn
  type     = "STANDARD"

  definition = templatefile("${path.module}/file_processor_workflow.asl.json", {
    processor_lambda_arn = aws_lambda_function.file_processor.arn
    sns_topic_arn        = aws_sns_topic.security_alerts.arn
  })
}
