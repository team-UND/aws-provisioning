# Elasticache Parameter Group for redis
resource "aws_elasticache_parameter_group" "beforegoingd_redis" {
  name        = "redis-${data.terraform_remote_state.vpc.outputs.shard_id}"
  description = "Beforegoing preprod Elasticache Redis Parameter Group"

  # Please use the right engine and version
  family = "redis7"

  # List of parameters
  parameter {
    name  = "cluster-enabled"
    value = "no"
  }

  parameter {
    name  = "maxmemory-policy"
    value = "volatile-lru"
  }
}
