from datetime import datetime
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
        s3_event = event["Records"][0]["s3"]
        bucket = s3_event["bucket"]["name"]
        key = s3_event["object"]["key"]

        timestamp = datetime.utcnow().isoformat()

        # FIXED: add UploadTimestamp
        table.put_item(
            Item={
                "Filename": key,
                "UploadTimestamp": timestamp,   
                "Bucket": bucket
            }
        )

        alert_message = None

        # Detect unencrypted uploads
        if not s3_event["object"].get("serverSideEncryption"):
            alert_message = f"Unencrypted file upload detected: {key}"

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
            "timestamp": timestamp,
            "alert_sent": bool(alert_message)
        }

    except Exception as e:
        print("Error:", str(e))

        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=f"Lambda failed: {str(e)}",
            Subject="Lambda Error"
        )
        raise
