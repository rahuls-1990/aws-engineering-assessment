import boto3
import os
import json
import datetime

sns = boto3.client("sns")
dynamo = boto3.client("dynamodb")

def lambda_handler(event, context):
    print("Event:", json.dumps(event))

    topic_arn = os.environ["SNS_TOPIC_ARN"]

    # Check encryption compliance
    s3_records = event.get("Records", [])
    if not s3_records:
        return {"status": "no records"}

    bucket = s3_records[0]["s3"]["bucket"]["name"]
    key = s3_records[0]["s3"]["object"]["key"]

    # Write file entry to DynamoDB
    dynamo.put_item(
        TableName="file-uploads",
        Item={
            "Filename": {"S": key},
            "Timestamp": {"S": str(datetime.datetime.utcnow())},
        }
    )

    return {"status": "success"}
    # Send SNS notification
    message = f"File {key} uploaded to bucket {bucket}."
    sns.publish(
        TopicArn=topic_arn,
        Message=message,
        Subject="S3 File Upload Notification"
    )   