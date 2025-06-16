output "aws_security_group_ec2_id" {
  description = "server name node security group"
  value       = module.server.aws_security_group_ec2_id
}

output "aws_autoscaling_group_name" {
  value = module.server.aws_autoscaling_group_name
}

output "aws_lb_target_group_external_name" {
  value = module.server.aws_lb_target_group_external_name
}
