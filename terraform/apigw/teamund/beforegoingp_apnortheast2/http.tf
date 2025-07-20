locals {
  shard_id = data.terraform_remote_state.vpc.outputs.shard_id
}

resource "aws_vpc_security_group_ingress_rule" "vpclink_http_lb" {
  description                  = "Allow HTTP traffic from the VPC Link to the LB"
  security_group_id            = data.terraform_remote_state.int_lb.outputs.aws_security_group_id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = module.http.aws_security_group_vpclink_id
}

module "http" {
  source = "../../_module/http"

  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_name = data.terraform_remote_state.vpc.outputs.vpc_name
  shard_id = local.shard_id

  domain_name        = data.terraform_remote_state.hosting_zone.outputs.aws_route53_zone_name
  subdomain_name     = "api"
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  lb_security_group_id = data.terraform_remote_state.int_lb.outputs.aws_security_group_id
  lb_listener_arn      = data.terraform_remote_state.int_lb.outputs.aws_lb_listener_http_arn
  lambda_integrations = {
    sentry = {
      arn : data.terraform_remote_state.function.outputs.aws_lambda_function_arn,
      route_key : "POST /sentry/{proxy+}"
    }
  }
  lb_route_key = "ANY /{proxy+}"

  cors_allow_methods = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
  cors_allow_headers = ["*"]

  throttling_burst_limit = 500
  throttling_rate_limit  = 500

  log_group_name        = "/apigw/${local.shard_id}"
  log_retention_in_days = 7
}
