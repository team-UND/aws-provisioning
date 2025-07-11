data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = merge(var.remote_state.vpc.beforegoingdapne2)
}

data "terraform_remote_state" "route53" {
  backend = "s3"

  config = merge(var.remote_state.route53.teamund.beforegoingdapne2)
}

data "terraform_remote_state" "iam" {
  backend = "s3"

  config = merge(var.remote_state.iam.teamund.beforegoingdapne2)
}

data "terraform_remote_state" "lb" {
  backend = "s3"

  config = merge(var.remote_state.networking.lb.beforegoingdapne2)
}
