output "aws_lb_target_group_default_name" {
  value = aws_lb_target_group.default.name
}

output "aws_security_group_ecs_tasks_id" {
  description = "The ID of the security group for the ECS tasks"
  value       = aws_security_group.ecs_tasks.id
}
