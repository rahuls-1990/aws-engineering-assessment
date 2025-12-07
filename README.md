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
s3 Bucket (secure-bucket-upload)

SSE enabled (AES256)
Lifecycle rule: Expire after 90 days
Lambda event notification for file uploads
Block public access
Files:
terraform/s3.tf

#### DynamoDB Table

Table name: file-uploads
Primary key: Filename (String)
SSE enabled
Provisioned capacity (5/5)

File:
terraform/dynamodb.tf

#### SNS Topic — security-alerts

Purpose: Alert security team if unencrypted resources appear.

Subscription:
✔ Email: security-team@example.com

Files:
sns.tf

#### IAM Roles & Policies

Lambda + Step Function roles with least-privilege:

DynamoDB: PutItem, DescribeTable

SNS: Publish

S3: GetObject

Step Functions execution permissions

File:
iam.tf

#### Lambda Function

Located under:

terraform/lambda/handler.py
terraform/lambda/function.zip


#### Lambda responsibilities:

Log S3 event

Start Step Function execution (future step)

Publish SNS alert if suspicious configuration found

File:
lambda.tf

#### Step Functions Workflow

Creates a simple orchestration:

Input validation
DynamoDB write
SNS failure notifications
File:
step-fn.tf

