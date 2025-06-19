resource "aws_lambda_function" "discord_notification" {
  function_name = "discord-notification-${data.terraform_remote_state.vpc.outputs.shard_id}"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  role          = data.terraform_remote_state.iam.outputs.aws_iam_role_lambda_execution_arn
  timeout       = 30
  memory_size   = 128

  filename         = "discord_notification.zip"
  source_code_hash = filebase64sha256("discord_notification.zip")

  environment {
    variables = {
      DISCORD_WEBHOOK_URL = var.discord_webhook_url
    }
  }

  tags = {
    Name        = "discord-notification-${data.terraform_remote_state.vpc.outputs.shard_id}"
    Environment = data.terraform_remote_state.vpc.outputs.billing_tag
  }
}

resource "aws_lambda_permission" "allow_sns_to_invoke_lambda" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.discord_notification.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = data.terraform_remote_state.sns.outputs.aws_sns_topic_codedeploy_arn
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = data.terraform_remote_state.sns.outputs.aws_sns_topic_codedeploy_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.discord_notification.arn
}
