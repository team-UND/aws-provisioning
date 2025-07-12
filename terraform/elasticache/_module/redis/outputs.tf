output "aws_security_group_id" {
  description = "The ID of the security group for the RDS"
  value       = aws_security_group.redis.id
}

output "port" {
  description = "The port the DB is listening on"
  value       = aws_elasticache_replication_group.redis_cluster.port
}
