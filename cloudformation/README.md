# Cloudformation assignment

Welcome to the Cloudformation assignment. In this assignment we kindly ask you to add additional security features to an existing cloudformation stack.
To be independent of any AWS accounts, we've prepared a docker-compose configuration that will start the [localstack](https://github.com/localstack) AWS cloud stack on your machine. 

Please see the usage section on how to authenticate.

# Assignment

The current, basic cloudformation template doesn't contain any additional security featuress/configurations. Please have a look at the cfn-nag report. There are a couple of findings which have to be fixed. Please extend the cloudformation template accordingly.

# Usage

## Start localstack

```shell
docker-compose up
```

Watch the logs for `Execution of "preload_services" took 986.95ms`

## Authentication
```shell
export AWS_ACCESS_KEY_ID=foobar
export AWS_SECRET_ACCESS_KEY=foobar
export AWS_REGION=eu-central-1
```

## AWS CLI examples
### S3
```shell
aws --endpoint-url http://localhost:4566 s3api list-buckets
```

## Create Stack
```shell
aws --endpoint-url http://localhost:4566 cloudformation create-stack --stack-name <STACK_NAME> --template-body file://stack.template --parameters ParameterKey=BucketName,ParameterValue=<BUCKET_NAME>
```

## CFN-NAG Report
### Show last report
```shell
docker logs cfn-nag
```
### Recreate report
```shell
docker-compose restart cfn-nag
```
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
