output "aws_ecs_cluster_default_id" {
  description = "The ID of the ECS cluster."
  value       = module.cluster.aws_ecs_cluster_default_id
}

output "aws_ecs_cluster_default_name" {
  description = "The name of the ECS cluster."
  value       = module.cluster.aws_ecs_cluster_default_name
}

output "aws_lb_external_dns_name" {
  value = module.cluster.aws_lb_external_dns_name
}

output "aws_lb_external_zone_id" {
  value = module.cluster.aws_lb_external_zone_id
}

output "aws_lb_listener_external_https_arn" {
  description = "The ARN of the default ALB's HTTPS listener."
  value       = module.cluster.aws_lb_listener_external_https_arn
}

output "aws_security_group_external_lb_id" {
  description = "The security group ID of the default ALB."
  value       = module.cluster.aws_security_group_external_lb_id
}
