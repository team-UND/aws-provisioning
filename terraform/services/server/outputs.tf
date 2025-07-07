output "aws_lb_target_group_default_name" {
  value = module.server.aws_lb_target_group_default_name
}

output "aws_security_group_ecs_tasks_id" {
  description = "The ID of the security group for the ECS tasks"
  value       = module.server.aws_security_group_ecs_tasks_id
}
