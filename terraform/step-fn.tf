resource "aws_iam_role" "stepfn_role" {
  name = "file-workflow-stepfn-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "states.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_role_policy" "stepfn_policy" {
  name = "file-workflow-stepfn-policy"
  role = aws_iam_role.stepfn_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Invoke Lambda
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = aws_lambda_function.file_processor.arn
      },

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


resource "aws_sfn_state_machine" "file_workflow" {
  name     = "file-upload-workflow"
  role_arn = aws_iam_role.stepfn_role.arn

  definition = jsonencode({
    Comment = "State machine for handling file uploads",
    StartAt = "InvokeLambda",
    States = {
      InvokeLambda = {
        Type = "Task",
        Resource = aws_lambda_function.file_processor.arn,
        Catch = [
          {
            ErrorEquals = ["States.ALL"],
            Next = "NotifyError"
          }
        ],
        End = true
      },

      NotifyError = {
        Type = "Task",
        Resource = "arn:aws:states:::sns:publish",
        Parameters = {
          TopicArn = aws_sns_topic.security_alerts.arn,
          Message  = "Lambda failed while processing the file upload."
        },
        End = true
      }
    }
  })
}

output "step_function_arn" {
  value = aws_sfn_state_machine.file_workflow.arn
}
