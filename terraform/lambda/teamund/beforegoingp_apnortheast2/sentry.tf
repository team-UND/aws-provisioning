data "aws_secretsmanager_secret" "app_secrets" {
  name = "prod/sentry/lambda"
}

locals {
  function_name = "sentry"
  vpc_name      = data.terraform_remote_state.vpc.outputs.vpc_name
  shard_id      = data.terraform_remote_state.vpc.outputs.shard_id
}

module "sentry" {
  source = "../../_module/function"

  aws_region  = data.terraform_remote_state.vpc.outputs.aws_region
  vpc_name    = local.vpc_name
  shard_id    = local.shard_id
  billing_tag = data.terraform_remote_state.vpc.outputs.billing_tag

  source_file_path = "${path.module}/${local.function_name}.py"
  output_path      = "${path.module}/${local.function_name}.zip"

  function_name = local.function_name
  handler       = "${local.function_name}.lambda_handler"
  role          = data.terraform_remote_state.iam.outputs.aws_iam_role_sentry_arn

  runtime     = "python3.12"
  timeout     = 30
  memory_size = 128

  env_variables = {
    DISCORD_SECRET_ARN = data.aws_secretsmanager_secret.app_secrets.arn
  }

  vpc_config = null

  log_group_name        = "/lambda/${local.function_name}/${local.shard_id}"
  log_retention_in_days = 7
}
