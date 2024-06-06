provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "source_bucket" {
  bucket = "source-bucket-name"
}

resource "aws_s3_bucket" "destination_bucket" {
  bucket = "destination-bucket-name"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "lambda_policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:*",
            "logs:*",
            "sns:Publish"
          ]
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_lambda_function" "s3_processor" {
  filename         = "lambda.zip"
  function_name    = "s3_processor"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("lambda.zip")
  environment {
    variables = {
      DESTINATION_BUCKET = aws_s3_bucket.destination_bucket.bucket
      SNS_TOPIC_ARN      = aws_sns_topic.notification_topic.arn
    }
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.source_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.source_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_sns_topic" "notification_topic" {
  name = "s3_processing_notifications"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.notification_topic.arn
  protocol  = "email"
  endpoint  = "your-email@example.com"
}

