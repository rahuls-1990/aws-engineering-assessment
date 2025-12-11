# Cloudformation

## CFN-NAG ouput 

Failures count: 0
Warnings count: 0

## Terraform
This project implements a secure, event-driven, serverless architecture using AWS services and
Terraform.

Architecture Overview:
1. S3 triggers Starter Lambda
2. Starter Lambda starts Step Functions
3. Step Functions invokes Processor Lambda
4. Processor Lambda writes DynamoDB + validates encryption
5. SNS sends security alerts.

## Why Step Functions?
- Orchestration, retries, extensibility, visibility
Components:
- S3 secure bucket or upload bucket
- DynamoDB encrypted table
- Lambda starter + processor
- SNS Alerts
- Step Functions workflow (external ASL JSON)

## Testing:
```shell
shell
docker-compose up -d
terraform init
terraform validate
terraform plan
terraform apply
```

- Variables:
    region, alert_email, uploads_bucket_name

- Outputs:
    processor_lambda_arn, starter_lambda_arn, state_machine_arn
