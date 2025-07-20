output "aws_security_group_id" {
  description = "The ID of the security group for the ElastiCache Redis cluster"
  value       = module.redis.aws_security_group_id
}

output "port" {
  description = "The port the ElastiCache Redis cluster is listening on"
  value       = module.redis.port
}
