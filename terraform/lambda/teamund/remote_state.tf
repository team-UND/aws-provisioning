data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = merge(var.remote_state.vpc.beforegoingdapne2)
}

data "terraform_remote_state" "hosting_zone" {
  backend = "s3"

  config = merge(var.remote_state.route53.hosting_zone.beforegoingdapne2)
}

data "terraform_remote_state" "iam" {
  backend = "s3"

  config = merge(var.remote_state.iam.teamund.beforegoingdapne2)
}

data "terraform_remote_state" "ext_lb" {
  backend = "s3"

  config = merge(var.remote_state.networking.ext_lb.beforegoingdapne2)
}
