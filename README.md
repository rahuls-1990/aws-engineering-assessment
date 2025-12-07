### Complete Ouput for cfn-nag report
```
Warnings count: 0
------------------------------------------------------------
/templates/stack.template
------------------------------------------------------------------------------------------------------------------------
| WARN W51
|
| Resource: ["S3Bucket"]
| Line Numbers: [13]
|
| S3 bucket should likely have a bucket policy
------------------------------------------------------------
| WARN W35
|
| Resource: ["S3Bucket"]
| Line Numbers: [13]
|
| S3 Bucket should have access logging configured

Failures count: 0
Warnings count: 2
------------------------------------------------------------
/templates/stack.template
------------------------------------------------------------------------------------------------------------------------
| WARN W51
|
| Resource: ["LoggingBucket", "S3Bucket"]
| Line Numbers: [14, 24]
|
| S3 bucket should likely have a bucket policy
------------------------------------------------------------
| WARN W35
|
| Resource: ["LoggingBucket"]
| Line Numbers: [14]
|
| S3 Bucket should have access logging configured
------------------------------------------------------------
| WARN W41
|
| Resource: ["LoggingBucket"]
| Line Numbers: [14]
|
| S3 Bucket should have encryption option set

Failures count: 0
Warnings count: 4
------------------------------------------------------------
/templates/stack.template
------------------------------------------------------------
Failures count: 0
Warnings count: 0
------------------------------------------------------------
/templates/stack.template
------------------------------------------------------------
Failures count: 0
Warnings count: 0
------------------------------------------------------------
/templates/stack.template
------------------------------------------------------------
Failures count: 0
Warnings count: 0
```


## Terraform Assignment

Note:

#### Terraform Setup
Start LocalStack
docker-compose up 

Initialize Terraform
```shell
terraform init
terraform plan
terraform apply
```
### Terraform Resources Implemented

```shell
terraform state list
aws_cloudwatch_log_group.file_processor_logs
aws_dynamodb_table.file_uploads
aws_iam_role.lambda_role
aws_iam_role.starter_lambda_role
aws_iam_role.stepfn_role
aws_iam_role_policy.lambda_policy
aws_iam_role_policy.starter_lambda_policy
aws_iam_role_policy.stepfn_policy
aws_lambda_function.file_processor
aws_lambda_function.starter_lambda
aws_lambda_permission.allow_s3
aws_lambda_permission.allow_s3_to_starter
aws_s3_bucket.uploads
aws_s3_bucket_notification.upload_events
aws_s3_bucket_notification.upload_events_starter
aws_s3_bucket_policy.uploads_tls_policy
aws_s3_bucket_public_access_block.uploads_public_access
aws_s3_bucket_server_side_encryption_configuration.uploads_sse
aws_s3_bucket_versioning.uploads_versioning
aws_sfn_state_machine.file_workflow
aws_sns_topic.security_alerts
aws_sns_topic_subscription.security_alerts_email
```

### 

        1. S3 Bucket — secure-bucket-upload

        Security & Compliance:

        ✔ Server-side encryption (AES256)

        ✔ Bucket versioning enabled

        ✔ TLS-only access enforced (aws:SecureTransport)

        ✔ Full public access block

        ✔ 90-day lifecycle expiration

        ✔ Event notifications to two Lambdas (starter + processor)

        File: terraform/s3.tf

        2. DynamoDB Table — file-uploads

        Schema:

        Attribute	Type
        Filename	S
        UploadTimestamp	S

        Features:

        PAY_PER_REQUEST

        Server-side encryption

        Point-in-time recovery

        File: terraform/dynamodb.tf

        3. SNS Topic — security-alerts

        Used for:

        reporting unencrypted uploads

        lambda errors

        Step Function failures

        An email subscription is included.

        File: terraform/sns.tf

        4. IAM Roles & Policies

        Principle of least privilege implemented for:

        → Starter Lambda Role

        states:StartExecution

        CloudWatch Logs permissions

        → Processor Lambda Role

        dynamodb:PutItem

        sns:Publish

        CloudWatch Logs permissions

        → Step Functions Role

        lambda:InvokeFunction

        sns:Publish (on workflow errors)

        File: terraform/iam.tf

        5. Lambda Functions

        A. Starter Lambda — file-upload-starter

        Files:

        terraform/lambda/lambda_starter_handler.py
        
        Responsibilities:

        Receive S3 event

        Start Step Function execution

        Log execution ARN

        Ensure unified workflow handling

        B. Processor Lambda — file-processor

        Files:

        terraform/lambda/handler.py
        terraform/lambda/function.zip

        Responsibilities:

            Parse file metadata

            Write entry to DynamoDB

            Detect missing encryption

            Publish SNS alerts

            Respond with structured output for Step Functions

            6. Step Functions Workflow — file-upload-workflow

            Workflow definition includes:

            ✔ ProcessFile Task

            Invokes processor Lambda

            Retries with exponential backoff

            ✔ CheckAlert Choice State

            Branching based on:

            { "alert_sent": true | false }

            ✔ NotifyFailure Task

            SNS publish on workflow errors

            File: terraform/step-fn.tf


┌──────────────────────────┐
│     S3 Bucket Upload      │
│   secure-bucket-upload    │
└──────────────┬───────────┘
               │ S3 Event: ObjectCreated:*
               ▼
┌──────────────────────────┐
│   Starter Lambda          │
│ file-upload-starter       │
│ (Starts Step Functions)   │
└──────────────┬───────────┘
               │ start_execution()
               ▼
┌───────────────────────────────────────┐
│      Step Function Workflow           │
│      file-upload-workflow             │
│---------------------------------------│
│ Start → ProcessFile → CheckAlert → End│
│ Retry + Catch + SNS failure handling  │
└──────────────┬───────────────────────┘
               │ invokes Lambda
               ▼
┌──────────────────────────┐
│   Processor Lambda        │
│     file-processor        │
└──────────────┬───────────┘
               │
      ┌────────┴──────────────┐
      ▼                        ▼
┌───────────────┐      ┌──────────────────┐
│ DynamoDB Table │      │   SNS Alerts     │
│  file-uploads  │      │ security-alerts  │
└───────────────┘      └──────────────────┘

Flow Summary:
1️⃣ S3 upload triggers Starter Lambda  
2️⃣ Starter Lambda triggers Step Functions  
3️⃣ Step Functions → Processor Lambda  
4️⃣ Lambda writes DynamoDB + SNS alerts  
5️⃣ Step Functions handles success/failure paths  
