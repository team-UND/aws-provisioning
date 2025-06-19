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
