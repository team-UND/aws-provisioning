data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = merge(var.remote_state.vpc.beforegoingdapne2)
}

data "terraform_remote_state" "lambda" {
  backend = "s3"

  config = merge(var.remote_state.lambda.teamund.beforegoingdapne2)
}
