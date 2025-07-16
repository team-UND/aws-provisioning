data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = merge(var.remote_state.vpc.beforegoingdapne1)
}

data "terraform_remote_state" "repository" {
  backend = "s3"

  config = merge(var.remote_state.ecr.repository.beforegoingdapne1)
}

data "terraform_remote_state" "mysql" {
  backend = "s3"

  config = merge(var.remote_state.rds.mysql.beforegoingdapne1)
}

data "terraform_remote_state" "redis" {
  backend = "s3"

  config = merge(var.remote_state.elasticache.redis.beforegoingdapne1)
}

data "terraform_remote_state" "iam" {
  backend = "s3"

  config = merge(var.remote_state.iam.teamund.beforegoingdapne1)
}
