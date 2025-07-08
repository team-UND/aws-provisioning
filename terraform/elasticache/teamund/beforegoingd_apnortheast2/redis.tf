resource "aws_elasticache_subnet_group" "redis" {
  name       = "redis-${data.terraform_remote_state.vpc.outputs.shard_id}"
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_db_subnet_ids

  tags = {
    Name = "redis-${data.terraform_remote_state.vpc.outputs.shard_id}"
  }
}

resource "aws_elasticache_replication_group" "redis_cluster" {
  description          = "Redis replication group"
  replication_group_id = "redis-${data.terraform_remote_state.vpc.outputs.shard_id}"
  parameter_group_name = aws_elasticache_parameter_group.redis.name
  engine_version       = "7.0"
  port                 = var.port

  subnet_group_name  = aws_elasticache_subnet_group.redis.name
  security_group_ids = [aws_security_group.redis.id]

  node_type                  = "cache.t2.micro"
  num_cache_clusters         = 1
  multi_az_enabled           = false
  automatic_failover_enabled = false

  tags = {
    Name    = "redis-${data.terraform_remote_state.vpc.outputs.shard_id}"
    project = "beforegoing"
    role    = "redis"
    billing = data.terraform_remote_state.vpc.outputs.billing_tag
    stack   = data.terraform_remote_state.vpc.outputs.vpc_name
    region  = data.terraform_remote_state.vpc.outputs.aws_region
  }
}

# Route53 Record for elasticache
resource "aws_route53_record" "redis" {
  zone_id = data.terraform_remote_state.vpc.outputs.route53_internal_zone_id
  name    = var.internal_domain_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_elasticache_replication_group.redis_cluster.primary_endpoint_address]
}
