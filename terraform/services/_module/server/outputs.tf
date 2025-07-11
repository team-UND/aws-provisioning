output "aws_security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.default.id
}

output "aws_lb_target_group_name" {
  description = "The name of the target group"
  value       = aws_lb_target_group.default.name
}

output "aws_lb_target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.default.arn
}

output "domain_name" {
  description = "The name of the domain"
  value       = var.domain_name
}
