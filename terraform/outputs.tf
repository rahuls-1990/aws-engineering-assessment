output "starter_lambda_arn" {
  description = "ARN of the Lambda function triggered by S3 uploads"
  value       = aws_lambda_function.starter_lambda.arn
}

output "processor_lambda_arn" {
  description = "ARN of the Lambda function that processes files via Step Functions"
  value       = aws_lambda_function.file_processor.arn
}

output "state_machine_arn" {
  description = "ARN of the Step Functions workflow orchestrating file processing"
  value       = aws_sfn_state_machine.file_workflow.arn
}

output "uploads_bucket_name" {
  description = "Name of the S3 bucket used for uploading files"
  value       = aws_s3_bucket.uploads.bucket
}
