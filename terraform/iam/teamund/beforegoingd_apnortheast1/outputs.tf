output "aws_iam_role_ar_service_arn" {
  description = "ARN of the IAM role for App Runner to access ECR"
  value       = aws_iam_role.ar_service.arn
}

output "aws_iam_role_ar_instance_arn" {
  description = "ARN of the IAM role for App Runner instance"
  value       = aws_iam_role.ar_instance.arn
}
