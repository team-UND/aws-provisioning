output "aws_security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.default.id
}

output "aws_lb_target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.default.arn
}
