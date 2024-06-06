# Serverless_POC
serverless infrastructure using AWS Lambda and Terraform, integrated with GitHub for automatic code updates, and configured to process files uploaded to an S3 bucket.

Problem Statement:
Develop and deploy a serverless infrastructure using AWS Lambda and Terraform.
-Configure the environment to use Python 3 for Lambda functions.
Integrate with GitHub to automatically deploy code updates.
-Set up S3 bucket event triggers to initiate the Lambda function when a new content file is added.
-Create a Python function within the Lambda that processes the new file.
-Generate a new file based on the processing and move it to another specified S3 bucket.
- sendnotfication email notification with details.


Solution:
1.1 Install Terraform
Ensure you have Terraform installed on your machine.
1.2 Install AWS CLI
Install the AWS CLI tool for managing AWS services.
1.3 Configure AWS CLI
Configure the AWS CLI with your credentials
Step 2: Write Terraform Configuration
main.tf
Step 3: Create the Lambda Function
lambda_function.py

3.2 Package the Lambda Function
Create a deployment package:
zip lambda.zip lambda_function.py

Step 4: Deploy with Terraform
4.1 Initialize and Apply Terraform Configuration
Initialize the Terraform workspace:
terraform init
terraform apply

5.0 Set Up GitHub Actions for CI/CD
Create a .github/workflows/deploy.yml file in your repository

Step 6: Set Up S3 Bucket Event Triggers
This step is already configured in the main.tf file with the aws_s3_bucket_notification resource that sets up the event trigger to invoke the Lambda function when a new object is created in the source bucket.
