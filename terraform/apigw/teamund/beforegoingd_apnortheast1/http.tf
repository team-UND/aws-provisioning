resource "aws_vpc_security_group_ingress_rule" "vpclink_http_apprunner" {
  description                  = "Allow HTTP traffic from the VPC Link to App Runner"
  security_group_id            = data.terraform_remote_state.ar.outputs.aws_security_group_id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = module.http.aws_security_group_vpclink_id
}

module "http" {
  source = "../../_module/http"

  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_name           = data.terraform_remote_state.vpc.outputs.vpc_name
  shard_id           = data.terraform_remote_state.vpc.outputs.shard_id
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  authorizer_lambda_function_arn   = data.terraform_remote_state.function.outputs.authorizer_lambda_function_arn
  authorizer_lambda_invoke_arn     = data.terraform_remote_state.function.outputs.authorizer_lambda_function_invoke_arn
  authorizer_result_ttl_in_seconds = 300
  origin_verify_header_name        = data.terraform_remote_state.function.outputs.origin_verify_header_name

  target_security_group_id = data.terraform_remote_state.ar.outputs.aws_security_group_id
  proxy_integration_uri    = data.terraform_remote_state.ar.outputs.aws_apprunner_service_url
  lambda_integrations = {
    sentry = {
      arn : data.terraform_remote_state.function.outputs.sentry_lambda_function_arn,
      route_key : "POST /sentry"
    }
  }
  proxy_route_key = "ANY /{proxy+}"

  cors_allow_origins = [
    "https://${var.subdomain_name}.${data.terraform_remote_state.hosting_zone.outputs.aws_route53_zone_name}"
  ]
  cors_allow_methods = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
  cors_allow_headers = ["*"]

  throttling_burst_limit = 500
  throttling_rate_limit  = 500

  log_group_name        = "/apigw/${data.terraform_remote_state.vpc.outputs.shard_id}"
  log_retention_in_days = 7
}
