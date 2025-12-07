import json
import boto3
import os

sfn = boto3.client("stepfunctions")
STATE_MACHINE_ARN = os.environ["STATE_MACHINE_ARN"]

def lambda_handler(event, context):
    print("Received S3 Event:", json.dumps(event))

    response = sfn.start_execution(
        stateMachineArn=STATE_MACHINE_ARN,
        input=json.dumps(event)
    )

    return {
        "status": "started",
        "executionArn": response["executionArn"]
    }
