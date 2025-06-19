output "aws_sns_topic_codedeploy_arn" {
  description = "The ARN of the SNS topic for CodeDeploy notifications"
  value       = aws_sns_topic.codedeploy.arn
}
