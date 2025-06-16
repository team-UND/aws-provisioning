data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = merge(var.remote_state.vpc.beforegoingdapne2)
}

data "terraform_remote_state" "services" {
  backend = "s3"

  config = merge(var.remote_state.services.server.beforegoingdapne2)
}

data "terraform_remote_state" "iam" {
  backend = "s3"

  config = merge(var.remote_state.iam.teamund.beforegoingdapne2)
}

data "terraform_remote_state" "sns" {
  backend = "s3"

  config = merge(var.remote_state.sns.teamund.beforegoingdapne2)
}
