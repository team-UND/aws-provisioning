output "aws_iam_instance_profile_ec2_name" {
  description = "Name of the IAM instance profile for EC2 instances"
  value       = aws_iam_instance_profile.ec2.name
}

output "aws_iam_role_ecs_task_arn" {
  description = "ARN of the IAM role for ECS task"
  value       = aws_iam_role.ecs_task.arn
}

output "aws_iam_role_ecs_task_execution_arn" {
  description = "ARN of the IAM role for ECS task execution"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "aws_iam_role_sentry_arn" {
  description = "ARN of the IAM role for Sentry Lambda function"
  value       = aws_iam_role.sentry.arn
}
