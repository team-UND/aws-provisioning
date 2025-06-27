resource "aws_sns_topic" "codedeploy" {
  name = "codedeploy-notification-${data.terraform_remote_state.vpc.outputs.shard_id}"

  tags = {
    Name        = "codedeploy-notification-${data.terraform_remote_state.vpc.outputs.shard_id}"
    Environment = data.terraform_remote_state.vpc.outputs.billing_tag
  }
}

resource "aws_sns_topic_policy" "allow_codedeploy_to_publish_sns" {
  arn = aws_sns_topic.codedeploy.arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codedeploy.amazonaws.com"
        },
        Action   = "sns:Publish",
        Resource = aws_sns_topic.codedeploy.arn,
      }
    ]
  })
}

resource "aws_lambda_permission" "allow_sns_to_invoke" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = data.terraform_remote_state.lambda.outputs.aws_lambda_function_codedeploy_notification_function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.codedeploy.arn
}

resource "aws_sns_topic_subscription" "lambda_codedeploy" {
  topic_arn = aws_sns_topic.codedeploy.arn
  protocol  = "lambda"
  endpoint  = data.terraform_remote_state.lambda.outputs.aws_lambda_function_codedeploy_notification_arn
}
