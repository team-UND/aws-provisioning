output "aws_security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.default.id
}

output "domain_name" {
  description = "The name of the domain"
  value       = var.domain_name
}
