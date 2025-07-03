output "aws_security_group_ec2_id" {
  description = "prometheus name node security group"
  value       = module.prometheus.aws_security_group_ec2_id
}

output "aws_autoscaling_group_name" {
  value = module.prometheus.aws_autoscaling_group_name
}

output "aws_lb_target_group_external_name" {
  value = module.prometheus.aws_lb_target_group_external_name
}
