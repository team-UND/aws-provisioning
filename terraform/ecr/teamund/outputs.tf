output "aws_ecr_repository_beforegoingd_server_build_repository_url" {
  description = "The URL of the ECR repository for the Server application"
  value       = aws_ecr_repository.beforegoingd_server_build.repository_url
}

output "aws_ecr_repository_beforegoingd_prometheus_build_repository_url" {
  description = "The URL of the ECR repository for the Prometheus application"
  value       = aws_ecr_repository.beforegoingd_prometheus_build.repository_url
}
