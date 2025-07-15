output "aws_security_group_id" {
  description = "The ID of the App Runner security group"
  value       = aws_security_group.default.id
}
