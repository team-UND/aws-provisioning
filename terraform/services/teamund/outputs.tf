output "aws_security_group_id" {
  description = "The ID of the security group"
  value       = module.server.aws_security_group_id
}

output "aws_lb_target_group_name" {
  description = "The name of the target group"
  value       = module.server.aws_lb_target_group_name
}

output "aws_lb_target_group_arn" {
  description = "The ARN of the target group"
  value       = module.server.aws_lb_target_group_arn
}

output "domain_name" {
  description = "The name of the domain"
  value       = module.server.domain_name
}
