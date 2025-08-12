data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = merge(var.remote_state.vpc.beforegoingpapne1)
}

data "terraform_remote_state" "hosting_zone" {
  backend = "s3"

  config = merge(var.remote_state.route53.hosting_zone.beforegoingpapne1)
}

data "terraform_remote_state" "ar" {
  backend = "s3"

  config = merge(var.remote_state.ar.service.beforegoingpapne1)
}

data "terraform_remote_state" "function" {
  backend = "s3"

  config = merge(var.remote_state.lambda.function.beforegoingpapne1)
}
