import json
import boto3
import os

sfn = boto3.client("stepfunctions")
STATE_MACHINE_ARN = os.environ["STATE_MACHINE_ARN"]

def lambda_handler(event, context):
    print("Received S3 Event:", json.dumps(event))

    # Extract bucket and key safely
    try:
        record = event["Records"][0]
        bucket = record["s3"]["bucket"]["name"]
        key = record["s3"]["object"]["key"]
    except Exception as e:
        print("Error parsing S3 event:", e)
        raise e

    input_payload = {
        "bucket": bucket,
        "key": key
    }

    # Start Step Function execution
    try:
        response = sfn.start_execution(
            stateMachineArn=STATE_MACHINE_ARN,
            input=json.dumps(input_payload)
        )
    except Exception as e:
        print("Failed to start Step Function:", e)
        raise e

    return {
        "status": "started",
        "executionArn": response["executionArn"]
    }
