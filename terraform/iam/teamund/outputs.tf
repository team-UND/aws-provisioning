output "aws_iam_instance_profile_ec2_name" {
  value = aws_iam_instance_profile.ec2.name
}

output "aws_iam_role_ecs_task_execution_arn" {
  description = "ARN of the IAM role for ECS task execution"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "aws_iam_role_lambda_execution_arn" {
  value = aws_iam_role.lambda_execution.arn
}

output "aws_iam_openid_connect_provider_github_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}

output "aws_iam_role_github_oidc_arn" {
  value = aws_iam_role.github_oidc.arn
}
