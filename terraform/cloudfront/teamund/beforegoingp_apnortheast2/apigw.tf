data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer_except_host_header" {
  name = "Managed-AllViewerExceptHostHeader"
}

data "aws_secretsmanager_secret" "origin_verify" {
  provider = aws.vpc_region
  name     = "prod/origin-verify/cloudfront"
}

data "aws_secretsmanager_secret_version" "origin_verify" {
  provider  = aws.vpc_region
  secret_id = data.aws_secretsmanager_secret.origin_verify.id
}

locals {
  subdomain_name     = "api"
  api_domain_name    = "${local.subdomain_name}.${data.terraform_remote_state.hosting_zone.outputs.aws_route53_zone_name}"
  origin_domain_name = replace(data.terraform_remote_state.apigw.outputs.aws_apigatewayv2_api_api_endpoint, "https://", "")
  origin_path        = data.terraform_remote_state.apigw.outputs.aws_apigatewayv2_stage_name == "$default" ? "" : "/${data.terraform_remote_state.apigw.outputs.aws_apigatewayv2_stage_name}"
}

module "apigw" {
  source = "../../_module/distribution"

  domain_name = data.terraform_remote_state.hosting_zone.outputs.aws_route53_zone_name

  comment             = "CloudFront for API Gateway"
  default_root_object = null
  price_class         = "PriceClass_200"
  aliases             = [local.api_domain_name]

  origin_domain_name = local.origin_domain_name
  origin_path        = local.origin_path
  origin_id          = data.terraform_remote_state.apigw.outputs.aws_apigatewayv2_api_id

  origin_verify_secret      = data.aws_secretsmanager_secret_version.origin_verify.secret_string
  origin_verify_header_name = data.terraform_remote_state.function.outputs.origin_verify_header_name

  cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
  origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_except_host_header.id

  geo_restriction_type      = "none"
  geo_restriction_locations = []

  web_acl_id = data.terraform_remote_state.acl.outputs.cloudfront_aws_wafv2_web_acl_arn

  log_bucket        = data.terraform_remote_state.bucket.outputs.aws_s3_bucket_bucket_domain_name
  log_bucket_prefix = data.terraform_remote_state.bucket.outputs.aws_s3_bucket_lifecycle_configuration_rule_prefix
}

resource "aws_route53_record" "api" {
  zone_id = data.terraform_remote_state.hosting_zone.outputs.aws_route53_zone_id
  name    = local.subdomain_name
  type    = "A"

  alias {
    name                   = module.apigw.aws_cloudfront_distribution_domain_name
    zone_id                = module.apigw.aws_cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }
}
