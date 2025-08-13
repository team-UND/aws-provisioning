data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = merge(var.remote_state.vpc.beforegoingdapne1)
}

data "terraform_remote_state" "hosting_zone" {
  backend = "s3"

  config = merge(var.remote_state.route53.hosting_zone.beforegoingdapne1)
}

data "terraform_remote_state" "iam" {
  backend = "s3"

  config = merge(var.remote_state.iam.teamund.beforegoingdapne1)
}
