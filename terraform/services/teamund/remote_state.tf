data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = merge(var.remote_state.vpc.beforegoingdapne2)
}

data "terraform_remote_state" "hosting_zone" {
  backend = "s3"

  config = merge(var.remote_state.route53.hosting_zone.beforegoingdapne2)
}

data "terraform_remote_state" "repository" {
  backend = "s3"

  config = merge(var.remote_state.ecr.repository.beforegoingdapne2)
}

data "terraform_remote_state" "iam" {
  backend = "s3"

  config = merge(var.remote_state.iam.teamund.beforegoingdapne2)
}

data "terraform_remote_state" "ext_lb" {
  backend = "s3"

  config = merge(var.remote_state.networking.ext_lb.beforegoingdapne2)
}

data "terraform_remote_state" "cluster" {
  backend = "s3"

  config = merge(var.remote_state.ecs.cluster.beforegoingdapne2)
}

data "terraform_remote_state" "mysql" {
  backend = "s3"

  config = merge(var.remote_state.rds.mysql.beforegoingdapne2)
}

data "terraform_remote_state" "redis" {
  backend = "s3"

  config = merge(var.remote_state.elasticache.redis.beforegoingdapne2)
}
