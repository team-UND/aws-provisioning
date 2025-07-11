output "aws_ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.default.id
}

output "aws_ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.default.name
}

output "aws_ecs_capacity_provider_name" {
  description = "The name of the ECS Capacity Provider"
  value       = aws_ecs_capacity_provider.default.name
}
