from datetime import datetime
import boto3
import os
import json
import logging
from typing import Dict, Any, List
from botocore.exceptions import ClientError, BotoCoreError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients (reuse connections)
dynamodb = boto3.resource("dynamodb")
sns = boto3.client("sns")
s3 = boto3.client("s3")

# Constants
TABLE_NAME = os.environ.get("DDB_TABLE_NAME")
SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")

def lambda_handler(event: Dict[str, Any], context) -> Dict[str, Any]:
    """
    Process uploaded files by validating encryption and storing metadata.
    
    Args:
        event: Contains bucket and key information
        context: Lambda context object
        
    Returns:
        Dict containing processing status and any alerts
    """
    correlation_id = context.aws_request_id
    logger.info(f"[{correlation_id}] Processing event: {json.dumps(event)}")
    
    # Validate environment variables
    if not TABLE_NAME or not SNS_TOPIC_ARN:
        error_msg = "Missing required environment variables: DDB_TABLE_NAME or SNS_TOPIC_ARN"
        logger.error(f"[{correlation_id}] {error_msg}")
        raise ValueError(error_msg)

    # Validate input event
    if not isinstance(event, dict) or "bucket" not in event or "key" not in event:
        error_msg = "Invalid event format: expected {bucket, key}"
        logger.error(f"[{correlation_id}] {error_msg}")
        raise ValueError(error_msg)

    bucket = event["bucket"]
    key = event["key"]

    # Validate S3 object key
    if not key or not isinstance(key, str) or key.endswith("/"):
        error_msg = f"Invalid S3 object key: {key}"
        logger.error(f"[{correlation_id}] {error_msg}")
        raise ValueError(error_msg)

    logger.info(f"[{correlation_id}] Processing file: s3://{bucket}/{key}")
    
    table = dynamodb.Table(TABLE_NAME)
    timestamp = datetime.utcnow().isoformat()
    alert_messages: List[str] = []

    # Check S3 encryption
    try:
        head_response = s3.head_object(Bucket=bucket, Key=key)
        sse = head_response.get("ServerSideEncryption")
        
        if not sse:
            alert_msg = f"Unencrypted S3 object detected: s3://{bucket}/{key}"
            alert_messages.append(alert_msg)
            logger.warning(f"[{correlation_id}] {alert_msg}")
        else:
            logger.info(f"[{correlation_id}] S3 object encrypted with: {sse}")
            
    except ClientError as e:
        error_code = e.response['Error']['Code']
        alert_msg = f"S3 encryption check failed for {key}: {error_code} - {e.response['Error']['Message']}"
        alert_messages.append(alert_msg)
        logger.error(f"[{correlation_id}] {alert_msg}")
    except BotoCoreError as e:
        alert_msg = f"S3 service error while checking encryption for {key}: {str(e)}"
        alert_messages.append(alert_msg)
        logger.error(f"[{correlation_id}] {alert_msg}")

    # Check DynamoDB encryption
    try:
        dynamodb_client = boto3.client("dynamodb")
        desc_response = dynamodb_client.describe_table(TableName=TABLE_NAME)
        
        sse_info = desc_response["Table"].get("SSEDescription")
        encrypted = sse_info and sse_info.get("Status") == "ENABLED"
        
        if not encrypted:
            alert_msg = f"DynamoDB table '{TABLE_NAME}' is NOT encrypted"
            alert_messages.append(alert_msg)
            logger.warning(f"[{correlation_id}] {alert_msg}")
        else:
            logger.info(f"[{correlation_id}] DynamoDB table is encrypted")
            
    except ClientError as e:
        error_code = e.response['Error']['Code']
        alert_msg = f"DynamoDB encryption check failed: {error_code} - {e.response['Error']['Message']}"
        alert_messages.append(alert_msg)
        logger.error(f"[{correlation_id}] {alert_msg}")
    except BotoCoreError as e:
        alert_msg = f"DynamoDB service error: {str(e)}"
        alert_messages.append(alert_msg)
        logger.error(f"[{correlation_id}] {alert_msg}")

    # Store file metadata in DynamoDB
    try:
        table.put_item(
            Item={
                "Filename": key,
                "UploadTimestamp": timestamp,
                "Bucket": bucket,
                "CorrelationId": correlation_id
            }
        )
        logger.info(f"[{correlation_id}] Successfully stored metadata in DynamoDB")
        
    except ClientError as e:
        error_code = e.response['Error']['Code']
        alert_msg = f"Failed to write to DynamoDB: {error_code} - {e.response['Error']['Message']}"
        alert_messages.append(alert_msg)
        logger.error(f"[{correlation_id}] {alert_msg}")
    except BotoCoreError as e:
        alert_msg = f"DynamoDB service error during write: {str(e)}"
        alert_messages.append(alert_msg)
        logger.error(f"[{correlation_id}] {alert_msg}")

    # Send security alerts
    alert_sent = False
    for message in alert_messages:
        try:
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=f"[{correlation_id}] {message}",
                Subject="Security Alert - File Processing"
            )
            logger.info(f"[{correlation_id}] Alert sent: {message}")
            alert_sent = True
        except (ClientError, BotoCoreError) as e:
            logger.error(f"[{correlation_id}] Failed to send SNS alert: {str(e)}")

    result = {
        "status": "success",
        "bucket": bucket,
        "file": key,
        "timestamp": timestamp,
        "correlation_id": correlation_id,
        "alert_sent": alert_sent,
        "alerts": alert_messages
    }
    
    logger.info(f"[{correlation_id}] Processing completed: {len(alert_messages)} alerts generated")
    return result
