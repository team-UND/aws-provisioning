output "aws_ecr_repository_server_build_repository_url" {
  description = "The URL of the ECR repository for the server application"
  value       = aws_ecr_repository.server_build.repository_url
}
