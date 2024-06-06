import json
import boto3
import os

s3 = boto3.client('s3')
sns = boto3.client('sns')

def lambda_handler(event, context):
    destination_bucket = os.environ['DESTINATION_BUCKET']
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']

    for record in event['Records']:
        source_bucket = record['s3']['bucket']['name']
        object_key = record['s3']['object']['key']
        
        # Download the file from the source S3 bucket
        download_path = f'/tmp/{object_key}'
        s3.download_file(source_bucket, object_key, download_path)

        # Process the file (example: simply read the content)
        with open(download_path, 'r') as file:
            file_content = file.read()
        
        # Create new content (example: append text)
        new_content = file_content + "\nProcessed by Lambda."

        # Upload the new file to the destination S3 bucket
        new_object_key = f'processed-{object_key}'
        upload_path = f'/tmp/{new_object_key}'
        with open(upload_path, 'w') as file:
            file.write(new_content)

        s3.upload_file(upload_path, destination_bucket, new_object_key)
        
        # Send an SNS notification
        message = {
            "source_bucket": source_bucket,
            "object_key": object_key,
            "destination_bucket": destination_bucket,
            "new_object_key": new_object_key
        }
        sns.publish(
            TopicArn=sns_topic_arn,
            Message=json.dumps(message),
            Subject="S3 File Processed"
        )

    return {
        'statusCode': 200,
        'body': json.dumps('File processed successfully!')
    }

