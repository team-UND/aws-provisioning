# Security Group for redis elasticache
resource "aws_security_group" "redis" {
  name        = "redis-${var.shard_id}"
  description = "Redis Security Group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "redis-${var.shard_id}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "redis" {
  security_group_id            = aws_security_group.redis.id
  from_port                    = var.port
  to_port                      = var.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.referenced_security_group_id
  description                  = "Redis service port from application"
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "redis-${var.shard_id}"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "redis-${var.shard_id}"
  }
}

resource "aws_elasticache_replication_group" "redis_cluster" {
  description                = "Redis replication group"
  replication_group_id       = "redis-${var.shard_id}"
  engine                     = "redis"
  engine_version             = var.engine_version
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  node_type                  = var.node_type
  parameter_group_name       = aws_elasticache_parameter_group.redis.name

  port               = var.port
  subnet_group_name  = aws_elasticache_subnet_group.redis.name
  security_group_ids = [aws_security_group.redis.id]

  num_cache_clusters         = var.num_cache_clusters
  multi_az_enabled           = var.multi_az_enabled
  automatic_failover_enabled = var.automatic_failover_enabled

  tags = {
    Name = "redis-${var.shard_id}"
  }
}

# Route53 Record for elasticache
resource "aws_route53_record" "redis" {
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_elasticache_replication_group.redis_cluster.primary_endpoint_address]
}

# Elasticache Parameter Group for redis
resource "aws_elasticache_parameter_group" "redis" {
  name        = "redis-${var.shard_id}"
  description = "Redis Parameter Group"
  family      = var.family

  dynamic "parameter" {
    for_each = var.pg_variables.parameters[var.shard_id]
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
}
