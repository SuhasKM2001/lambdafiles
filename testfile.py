import json
import boto3
import os
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

def lambda_handler(event, context):
    bucket_name = os.environ.get('S3_BUCKET')
    
    try:
        body = json.loads(event["body"]) if "body" in event and event["body"] else {}
        file_key = body.get("file_key")
        
        if not file_key:
            return {"statusCode": 400, "body": json.dumps({"error": "Missing file_key parameter."})}
        
        # Initialize S3 client
        s3_client = boto3.client("s3")
        
        # Generate presigned URL
        presigned_url = s3_client.generate_presigned_url(
            "get_object",
            Params={"Bucket": bucket_name, "Key": file_key},
            ExpiresIn=3600  # URL expires in 1 hour
        )
        
        return {
            "statusCode": 200,
            "body": json.dumps({"download_url": presigned_url}),
            "headers": {"Content-Type": "application/json"}
        }
    
    except (NoCredentialsError, PartialCredentialsError):
        return {"statusCode": 500, "body": json.dumps({"error": "AWS credentials not found."})}
    except Exception as e:
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
