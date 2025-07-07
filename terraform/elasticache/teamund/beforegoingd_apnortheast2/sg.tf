# Security Group for redis elasticache
resource "aws_security_group" "beforegoingd_redis" {
  name        = "redis-${data.terraform_remote_state.vpc.outputs.shard_id}"
  description = "Beforegoing ElastiCache Redis Security Group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = {
    Name    = "redis-${data.terraform_remote_state.vpc.outputs.shard_id}-sg"
    project = "beforegoing"
    role    = "redis"
    stack   = data.terraform_remote_state.vpc.outputs.vpc_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "redis_ing" {
  security_group_id            = aws_security_group.beforegoingd_redis.id
  from_port                    = var.port
  to_port                      = var.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = data.terraform_remote_state.server.outputs.aws_security_group_ecs_tasks_id
  description                  = "Internal redis service port from beforegoing application"
}

resource "aws_vpc_security_group_egress_rule" "redis_eg" {
  security_group_id = aws_security_group.beforegoingd_redis.id
  from_port         = var.port
  to_port           = var.port
  ip_protocol       = "tcp"
  cidr_ipv4         = data.terraform_remote_state.vpc.outputs.cidr_block
  description       = "Internal redis service port outbound"
}
