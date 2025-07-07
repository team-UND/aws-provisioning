output "aws_ecs_cluster_default_id" {
  description = "The ID of the ECS cluster."
  value       = aws_ecs_cluster.default.id
}

output "aws_ecs_cluster_default_name" {
  description = "The name of the ECS cluster."
  value       = aws_ecs_cluster.default.name
}

output "aws_lb_external_dns_name" {
  value = aws_lb.external.dns_name
}

output "aws_lb_external_zone_id" {
  value = aws_lb.external.zone_id
}

output "aws_lb_listener_external_https_arn" {
  description = "The ARN of the default ALB's HTTPS listener."
  value       = aws_lb_listener.external_https.arn
}

output "aws_security_group_external_lb_id" {
  description = "The security group ID of the default ALB."
  value       = aws_security_group.external_lb.id
}
