output "aws_ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.default.id
}

output "aws_ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.default.name
}

output "aws_ecs_capacity_provider_ec2_name" {
  description = "The name of the default EC2 Capacity Provider"
  value       = aws_ecs_capacity_provider.ec2.name
}
