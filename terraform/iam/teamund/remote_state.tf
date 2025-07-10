data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = merge(var.remote_state.vpc.beforegoingdapne2)
}

data "terraform_remote_state" "ecr" {
  backend = "s3"

  config = merge(var.remote_state.ecr.teamund.beforegoingdapne2)
}
