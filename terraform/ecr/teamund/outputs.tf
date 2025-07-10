output "aws_ecr_repository_beforegoingd_server_build_arn" {
  description = "The ARN of the ECR repository for the Server application"
  value       = module.beforegoingd_server_repository.aws_ecr_repository_arn
}

output "aws_ecr_repository_beforegoingd_server_build_repository_url" {
  description = "The URL of the ECR repository for the Server application"
  value       = module.beforegoingd_server_repository.aws_ecr_repository_url
}

output "aws_ecr_repository_beforegoingd_prometheus_build_arn" {
  description = "The ARN of the ECR repository for the Prometheus application"
  value       = module.beforegoingd_prometheus_repository.aws_ecr_repository_arn
}

output "aws_ecr_repository_beforegoingd_prometheus_build_repository_url" {
  description = "The URL of the ECR repository for the Prometheus application"
  value       = module.beforegoingd_prometheus_repository.aws_ecr_repository_url
}
