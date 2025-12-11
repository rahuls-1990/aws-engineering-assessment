from datetime import datetime
import boto3
import os
import json

dynamodb = boto3.resource("dynamodb")
sns = boto3.client("sns")
s3 = boto3.client("s3")

TABLE_NAME = os.environ["DDB_TABLE_NAME"]
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]

def lambda_handler(event, context):
    print("Received event:", json.dumps(event))


    if "bucket" not in event or "key" not in event:
        raise ValueError("Invalid event format: expected {bucket, key}")

    bucket = event["bucket"]
    key = event["key"]

    # Reject invalid object keys (folders, empty keys)
    if not key or key.endswith("/"):
        raise ValueError(f"Invalid S3 object key: {key}")

    table = dynamodb.Table(TABLE_NAME)
    timestamp = datetime.utcnow().isoformat()

    alert_messages = []


    try:
        head = s3.head_object(Bucket=bucket, Key=key)
        sse = head.get("ServerSideEncryption")

        if not sse:
            alert_messages.append(f"Unencrypted S3 object detected: {key}")
    except Exception as e:
        alert_messages.append(f"Could not check S3 encryption: {str(e)}")


    try:
        dynamodb_client = boto3.client("dynamodb")
        desc = dynamodb_client.describe_table(TableName=TABLE_NAME)

        sse_info = desc["Table"].get("SSEDescription")
        encrypted = sse_info and sse_info.get("Status") == "ENABLED"

        if not encrypted:
            alert_messages.append(f"DynamoDB table '{TABLE_NAME}' is NOT encrypted.")

    except Exception as e:
        alert_messages.append(f"Could not check DynamoDB encryption: {str(e)}")

   
    try:
        table.put_item(
            Item={
                "Filename": key,
                "UploadTimestamp": timestamp,
                "Bucket": bucket,
            }
        )
    except Exception as e:
        alert_messages.append(f"Failed to write to DynamoDB: {str(e)}")


    alert_sent = False

    for message in alert_messages:
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=message,
            Subject="Security Alert"
        )
        print("Alert sent:", message)
        alert_sent = True

    return {
        "status": "success",
        "bucket": bucket,
        "file": key,
        "timestamp": timestamp,
        "alert_sent": alert_sent,
        "alerts": alert_messages
    }
