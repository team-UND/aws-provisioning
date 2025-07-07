output "aws_security_group_ec2_id" {
  description = "ec2 instance security group"
  value       = aws_security_group.ec2.id
}

output "aws_autoscaling_group_name" {
  value = aws_autoscaling_group.default.name
}

output "aws_lb_target_group_external_name" {
  value = aws_lb_target_group.external.name
}
