output "aws_ecs_cluster_id" {
  description = "The ID of the ECS cluster."
  value       = module.cluster.aws_ecs_cluster_id
}

output "aws_ecs_cluster_name" {
  description = "The name of the ECS cluster."
  value       = module.cluster.aws_ecs_cluster_name
}

output "aws_ecs_capacity_provider_ec2_name" {
  description = "The name of the default EC2 Capacity Provider."
  value       = module.cluster.aws_ecs_capacity_provider_ec2_name
}
