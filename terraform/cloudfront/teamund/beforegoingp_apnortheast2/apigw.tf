data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
}

locals {
  subdomain_name     = "api"
  api_domain_name    = "${local.subdomain_name}.${data.terraform_remote_state.hosting_zone.outputs.aws_route53_zone_name}"
  origin_domain_name = replace(data.terraform_remote_state.apigw.outputs.aws_apigatewayv2_api_api_endpoint, "https://", "")
  origin_path        = data.terraform_remote_state.apigw.outputs.stage_name == "$default" ? "" : "/${data.terraform_remote_state.apigw.outputs.stage_name}"
}

# Generate a random secret for the origin verification header
resource "random_string" "default" {
  length  = 32
  special = false
}

# Store the secret securely in AWS Secrets Manager
resource "aws_secretsmanager_secret" "default" {
  name = "prod/origin-verify/cloudfront"
}

resource "aws_secretsmanager_secret_version" "default" {
  secret_id     = aws_secretsmanager_secret.default.id
  secret_string = random_string.default.result
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

  origin_custom_header_secret = random_string.default.result

  cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
  origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id

  geo_restriction_type      = "none"
  geo_restriction_locations = []

  acm_certificate_arn = data.aws_acm_certificate.default.arn
  web_acl_id          = data.terraform_remote_state.waf.outputs.cloudfront_web_acl_arn

  log_bucket        = null
  log_bucket_prefix = ""
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
