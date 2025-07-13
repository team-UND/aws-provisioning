data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = merge(var.remote_state.vpc.beforegoingdapne2)
}

data "terraform_remote_state" "repository" {
  backend = "s3"

  config = merge(var.remote_state.ecr.repository.beforegoingdapne2)
}

data "terraform_remote_state" "mysql" {
  backend = "s3"

  config = merge(var.remote_state.rds.mysql.beforegoingdapne2)
}
