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
      # Allow Step Functions to invoke the Lambda
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = aws_lambda_function.file_processor.arn
      },
      # Allow Step Functions to publish SNS (on workflow failure)
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = aws_sns_topic.security_alerts.arn
      }
    ]
  })
}

# State machine definition
resource "aws_sfn_state_machine" "file_workflow" {
  name     = "file-upload-workflow"
  role_arn = aws_iam_role.stepfn_role.arn

  definition = jsonencode({
    Comment = "File upload processing workflow with Lambda + SNS alerts",
    StartAt = "ProcessFile",
    States = {
      ProcessFile = {
        Type       = "Task",
        Resource   = "arn:aws:states:::lambda:invoke",
        OutputPath = "$.Payload",
        Parameters = {
          "FunctionName" = aws_lambda_function.file_processor.arn,
          "Payload.$"    = "$"
        },
        Retry = [
          {
            ErrorEquals     = ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException"],
            IntervalSeconds = 2,
            MaxAttempts     = 3,
            BackoffRate     = 2.0
          }
        ],
        Catch = [
          {
            ErrorEquals = ["States.ALL"],
            ResultPath  = "$.error",
            Next        = "NotifyFailure"
          }
        ],
        Next = "CheckAlert"
      },

      CheckAlert = {
        Type = "Choice",
        Choices = [
          {
            Variable      = "$.alert_sent",
            BooleanEquals = true,
            Next          = "AlertHandled"
          }
        ],
        Default = "NoAlert"
      },

      AlertHandled = {
        Type = "Succeed"
      },

      NoAlert = {
        Type = "Succeed"
      },

      NotifyFailure = {
        Type     = "Task",
        Resource = "arn:aws:states:::sns:publish",
        Parameters = {
          "TopicArn"  = aws_sns_topic.security_alerts.arn,
          "Message.$" = "States.Format('Step Function failed: {}', $.error)"
        },
        End = true
      }
    }
  })
}
