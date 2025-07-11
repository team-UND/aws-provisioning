data "aws_secretsmanager_secret" "app_secrets" {
  name = "Lambda-Secrets"
}

locals {
  function_name = "sentry"
  shard_id      = data.terraform_remote_state.vpc.outputs.shard_id
}

module "function" {
  source = "../../_module/function"

  aws_region  = data.terraform_remote_state.vpc.outputs.aws_region
  shard_id    = local.shard_id
  billing_tag = data.terraform_remote_state.vpc.outputs.billing_tag

  source_file_path = "${path.module}/function.py"
  output_path      = "${path.module}/function.zip"

  function_name = local.function_name
  handler       = "function.lambda_handler"
  role          = data.terraform_remote_state.iam.outputs.aws_iam_role_lambda_execution_arn

  runtime     = "python3.12"
  timeout     = 30
  memory_size = 128

  env_variables = {
    DISCORD_SECRET_ARN = data.aws_secretsmanager_secret.app_secrets.arn
  }

  lb_https_listener_arn  = data.terraform_remote_state.external_lb.outputs.aws_lb_listener_https_arn
  listener_rule_priority = 150
  domain_name            = "sentry.${data.terraform_remote_state.hosting_zone.outputs.aws_route53_zone_name}"
  route53_zone_id        = var.r53_variables.dev.beforegoing_site_zone_id
  lb_dns_name            = data.terraform_remote_state.external_lb.outputs.aws_lb_dns_name
  lb_zone_id             = data.terraform_remote_state.external_lb.outputs.aws_lb_zone_id

  log_group_name        = "/lambda/${local.shard_id}/${local.function_name}"
  log_retention_in_days = 7
}
