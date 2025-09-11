data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = merge(var.remote_state.vpc.beforegoingsapne2)
}

data "terraform_remote_state" "repository" {
  backend = "s3"

  config = merge(var.remote_state.ecr.repository.beforegoingsapne2)
}

data "terraform_remote_state" "iam" {
  backend = "s3"

  config = merge(var.remote_state.iam.teamund.global)
}

data "terraform_remote_state" "mysql" {
  backend = "s3"

  config = merge(var.remote_state.rds.mysql.beforegoingsapne2)
}
