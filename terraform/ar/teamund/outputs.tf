output "aws_security_group_id" {
  description = "The ID of the App Runner security group"
  value       = module.service.aws_security_group_id
}

output "aws_apprunner_service_url" {
  description = "The URL of the App Runner service"
  value       = module.service.aws_apprunner_service_url
}
