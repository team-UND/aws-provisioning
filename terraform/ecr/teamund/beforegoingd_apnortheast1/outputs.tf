output "aws_ecr_repository_server_build_arn" {
  description = "The ARN of the ECR repository for the Server application"
  value       = module.server_repository.aws_ecr_repository_arn
}

output "aws_ecr_repository_server_build_repository_url" {
  description = "The URL of the ECR repository for the Server application"
  value       = module.server_repository.aws_ecr_repository_url
}
