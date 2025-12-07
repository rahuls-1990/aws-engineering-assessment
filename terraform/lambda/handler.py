import boto3
import os
import json

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

TABLE_NAME = os.environ["DDB_TABLE_NAME"]
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]

def lambda_handler(event, _):
    print("Received event:", json.dumps(event))

    table = dynamodb.Table(TABLE_NAME)

    try:
        # Extract S3 information
        s3_event = event["Records"][0]["s3"]
        bucket = s3_event["bucket"]["name"]
        key = s3_event["object"]["key"]

        # Write metadata to DynamoDB
        table.put_item(
            Item={
                "Filename": key,
                "Bucket": bucket
            }
        )

        alert_message = None

        # Example security condition: file uploaded without encryption
        if not s3_event["object"].get("serverSideEncryption"):
            alert_message = f"Unencrypted file upload detected: {key}"

        # Send SNS alert only if needed
        if alert_message:
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=alert_message,
                Subject="Security Alert: Unencrypted Upload"
            )
            print("Security alert sent:", alert_message)

        return {
            "status": "success",
            "file": key,
            "bucket": bucket,
            "alert_sent": bool(alert_message)
        }

    except Exception as e:
        print("Error:", str(e))

        # Send SNS alert on failure
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=f"Lambda failed: {str(e)}",
            Subject="Lambda Error"
        )

        raise
