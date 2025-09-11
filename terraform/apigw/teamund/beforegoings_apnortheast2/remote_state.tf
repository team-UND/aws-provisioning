data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = merge(var.remote_state.vpc.beforegoingsapne2)
}

data "terraform_remote_state" "hosting_zone" {
  backend = "s3"

  config = merge(var.remote_state.route53.hosting_zone.beforegoingsapne2)
}

data "terraform_remote_state" "int_lb" {
  backend = "s3"

  config = merge(var.remote_state.lb.internal.beforegoingsapne2)
}

data "terraform_remote_state" "function" {
  backend = "s3"

  config = merge(var.remote_state.lambda.function.beforegoingsapne2)
}
