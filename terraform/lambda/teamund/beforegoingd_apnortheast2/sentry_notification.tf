data "archive_file" "sentry_notification_zip" {
  type        = "zip"
  source_file = "${path.module}/sentry_notification.py"
  output_path = "${path.module}/sentry_notification.zip"
}

resource "aws_lambda_function" "sentry_notification" {
  function_name = "sentry-notification-${data.terraform_remote_state.vpc.outputs.shard_id}"
  handler       = "sentry_notification.lambda_handler"
  runtime       = "python3.12"
  role          = data.terraform_remote_state.iam.outputs.aws_iam_role_lambda_execution_arn
  timeout       = 30
  memory_size   = 128

  filename         = data.archive_file.sentry_notification_zip.output_path
  source_code_hash = data.archive_file.sentry_notification_zip.output_base64sha256

  environment {
    variables = {
      DISCORD_WEBHOOK_URL = var.discord_webhook_url
    }
  }

  tags = {
    Name        = "sentry-notification-${data.terraform_remote_state.vpc.outputs.shard_id}"
    Environment = data.terraform_remote_state.vpc.outputs.billing_tag
  }
}
