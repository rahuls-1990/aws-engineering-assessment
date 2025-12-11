import json
import boto3
import os
import logging
from typing import Dict, Any
from botocore.exceptions import ClientError, BotoCoreError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS client
sfn = boto3.client("stepfunctions")
STATE_MACHINE_ARN = os.environ.get("STATE_MACHINE_ARN")

def lambda_handler(event: Dict[str, Any], context) -> Dict[str, Any]:
    """
    Triggered by S3 events to start Step Functions workflow for file processing.
    
    Args:
        event: S3 event notification
        context: Lambda context object
        
    Returns:
        Dict containing execution status and ARN
    """
    correlation_id = context.aws_request_id
    logger.info(f"[{correlation_id}] Received S3 Event: {json.dumps(event)}")
    
    # Validate environment variables
    if not STATE_MACHINE_ARN:
        error_msg = "Missing required environment variable: STATE_MACHINE_ARN"
        logger.error(f"[{correlation_id}] {error_msg}")
        raise ValueError(error_msg)

    # Validate and extract S3 event data
    try:
        if not isinstance(event, dict) or "Records" not in event:
            raise ValueError("Invalid S3 event format: missing Records")
            
        if not event["Records"] or len(event["Records"]) == 0:
            raise ValueError("Invalid S3 event format: empty Records")
            
        record = event["Records"][0]
        
        # Validate S3 record structure
        if "s3" not in record:
            raise ValueError("Invalid S3 record: missing s3 section")
            
        s3_data = record["s3"]
        if "bucket" not in s3_data or "object" not in s3_data:
            raise ValueError("Invalid S3 record: missing bucket or object")
            
        bucket = s3_data["bucket"]["name"]
        key = s3_data["object"]["key"]
        
        # Validate extracted data
        if not bucket or not key:
            raise ValueError(f"Invalid S3 data: bucket='{bucket}', key='{key}'")
            
        logger.info(f"[{correlation_id}] Processing S3 object: s3://{bucket}/{key}")
        
    except (KeyError, IndexError, TypeError) as e:
        error_msg = f"Error parsing S3 event structure: {str(e)}"
        logger.error(f"[{correlation_id}] {error_msg}")
        raise ValueError(error_msg)
    except ValueError as e:
        logger.error(f"[{correlation_id}] {str(e)}")
        raise

    # Prepare Step Functions input
    input_payload = {
        "bucket": bucket,
        "key": key,
        "correlation_id": correlation_id
    }

    # Start Step Function execution
    try:
        response = sfn.start_execution(
            stateMachineArn=STATE_MACHINE_ARN,
            name=f"file-processing-{correlation_id}",
            input=json.dumps(input_payload)
        )
        
        execution_arn = response["executionArn"]
        logger.info(f"[{correlation_id}] Started Step Function execution: {execution_arn}")
        
        return {
            "status": "started",
            "executionArn": execution_arn,
            "correlation_id": correlation_id,
            "bucket": bucket,
            "key": key
        }
        
    except ClientError as e:
        error_code = e.response['Error']['Code']
        error_msg = f"Failed to start Step Function: {error_code} - {e.response['Error']['Message']}"
        logger.error(f"[{correlation_id}] {error_msg}")
        raise RuntimeError(error_msg)
    except BotoCoreError as e:
        error_msg = f"Step Functions service error: {str(e)}"
        logger.error(f"[{correlation_id}] {error_msg}")
        raise RuntimeError(error_msg)
