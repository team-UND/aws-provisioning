data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = merge(var.remote_state.vpc.beforegoingsapne2)
}

data "terraform_remote_state" "repository" {
  backend = "s3"

  config = merge(var.remote_state.ecr.repository.beforegoingsapne2)
}

data "terraform_remote_state" "mysql" {
  backend = "s3"

  config = merge(var.remote_state.rds.mysql.beforegoingsapne2)
}

data "terraform_remote_state" "redis" {
  backend = "s3"

  config = merge(var.remote_state.elasticache.redis.beforegoingsapne2)
}

data "terraform_remote_state" "iam" {
  backend = "s3"

  config = merge(var.remote_state.iam.teamund.beforegoingsapne2)
}

data "terraform_remote_state" "int_lb" {
  backend = "s3"

  config = merge(var.remote_state.lb.internal.beforegoingsapne2)
}

data "terraform_remote_state" "cluster" {
  backend = "s3"

  config = merge(var.remote_state.ecs.cluster.beforegoingsapne2)
}
