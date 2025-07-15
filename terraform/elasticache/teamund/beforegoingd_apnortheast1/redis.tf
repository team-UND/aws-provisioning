module "redis" {
  source = "../../_module/redis"

  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_name   = data.terraform_remote_state.vpc.outputs.vpc_name
  shard_id   = data.terraform_remote_state.vpc.outputs.shard_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_db_subnet_ids

  route53_zone_id = data.terraform_remote_state.vpc.outputs.route53_internal_zone_id
  domain_name     = "redis-dev"
  port            = 6079

  engine_version             = "7.0"
  auto_minor_version_upgrade = true
  node_type                  = "cache.t2.micro"
  num_cache_clusters         = 1
  multi_az_enabled           = false
  automatic_failover_enabled = false

  family       = "redis7"
  pg_variables = var.pg_variables
}
