data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = merge(var.remote_state.vpc.beforegoingpapne2)
}

data "terraform_remote_state" "hosting_zone" {
  backend = "s3"

  config = merge(var.remote_state.route53.hosting_zone.beforegoingpapne2)
}

data "terraform_remote_state" "acl" {
  backend = "s3"

  config = merge(var.remote_state.waf.acl.beforegoingpapne2)
}

data "terraform_remote_state" "apigw" {
  backend = "s3"

  config = merge(var.remote_state.apigw.http.beforegoingpapne2)
}
