data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = merge(var.remote_state.vpc.beforegoingsapne2)
}

data "terraform_remote_state" "hosting_zone" {
  backend = "s3"

  config = merge(var.remote_state.route53.hosting_zone.beforegoingshop)
}

data "terraform_remote_state" "bucket" {
  backend = "s3"

  config = merge(var.remote_state.s3.bucket.beforegoingsapne2)
}

data "terraform_remote_state" "acl" {
  backend = "s3"

  config = merge(var.remote_state.waf.acl.beforegoingsapne2)
}

data "terraform_remote_state" "function" {
  backend = "s3"

  config = merge(var.remote_state.lambda.function.beforegoingsapne2)
}

data "terraform_remote_state" "apigw" {
  backend = "s3"

  config = merge(var.remote_state.apigw.http.beforegoingsapne2)
}
