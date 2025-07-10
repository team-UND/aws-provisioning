output "aws_ecr_repository_arn" {
  description = "The ARN of the ECR repository for the application"
  value       = aws_ecr_repository.default.arn
}

output "aws_ecr_repository_url" {
  description = "The URL of the ECR repository for the application"
  value       = aws_ecr_repository.default.repository_url
}
