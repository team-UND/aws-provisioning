data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = merge(var.remote_state.vpc.beforegoingpapne2)
}

data "terraform_remote_state" "hosting_zone" {
  backend = "s3"

  config = merge(var.remote_state.route53.hosting_zone.beforegoingpapne2)
}

data "terraform_remote_state" "repository" {
  backend = "s3"

  config = merge(var.remote_state.ecr.repository.beforegoingpapne2)
}

data "terraform_remote_state" "mysql" {
  backend = "s3"

  config = merge(var.remote_state.rds.mysql.beforegoingpapne2)
}

data "terraform_remote_state" "redis" {
  backend = "s3"

  config = merge(var.remote_state.elasticache.redis.beforegoingpapne2)
}

data "terraform_remote_state" "iam" {
  backend = "s3"

  config = merge(var.remote_state.iam.teamund.beforegoingpapne2)
}

data "terraform_remote_state" "int_lb" {
  backend = "s3"

  config = merge(var.remote_state.lb.internal.beforegoingpapne2)
}

data "terraform_remote_state" "cluster" {
  backend = "s3"

  config = merge(var.remote_state.ecs.cluster.beforegoingpapne2)
}
