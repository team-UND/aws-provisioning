output "aws_security_group_id" {
  description = "The ID of the security group"
  value       = module.server.aws_security_group_id
}
