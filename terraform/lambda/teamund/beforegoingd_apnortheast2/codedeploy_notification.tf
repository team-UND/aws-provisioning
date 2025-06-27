data "archive_file" "codedeploy_notification_zip" {
  type        = "zip"
  source_file = "${path.module}/codedeploy_notification.py"
  output_path = "${path.module}/codedeploy_notification.zip"
}

resource "aws_lambda_function" "codedeploy_notification" {
  function_name = "codedeploy-notification-${data.terraform_remote_state.vpc.outputs.shard_id}"
  handler       = "codedeploy_notification.lambda_handler"
  runtime       = "python3.12"
  role          = data.terraform_remote_state.iam.outputs.aws_iam_role_lambda_execution_arn
  timeout       = 30
  memory_size   = 128

  filename         = data.archive_file.codedeploy_notification_zip.output_path
  source_code_hash = data.archive_file.codedeploy_notification_zip.output_base64sha256

  environment {
    variables = {
      DISCORD_WEBHOOK_URL = var.discord_webhook_url
    }
  }

  tags = {
    Name        = "codedeploy-notification-${data.terraform_remote_state.vpc.outputs.shard_id}"
    Environment = data.terraform_remote_state.vpc.outputs.billing_tag
  }
}
