data "aws_secretsmanager_secret" "sentry_lambda" {
  name = "stg/sentry/lambda"
}

module "sentry" {
  source = "../../_module/function"

  aws_region  = data.terraform_remote_state.vpc.outputs.aws_region
  vpc_name    = local.vpc_name
  shard_id    = local.shard_id
  billing_tag = data.terraform_remote_state.vpc.outputs.billing_tag

  source_file_path = "${path.module}/${var.sentry_function_name}.py"
  output_path      = "${path.module}/${var.sentry_function_name}.zip"

  function_name = var.sentry_function_name
  handler       = "${var.sentry_function_name}.lambda_handler"
  role          = data.terraform_remote_state.iam.outputs.aws_iam_role_sentry_arn

  runtime     = var.sentry_runtime
  timeout     = var.sentry_timeout
  memory_size = var.sentry_memory_size

  env_variables = {
    DISCORD_SECRET_ARN = data.aws_secretsmanager_secret.sentry_lambda.arn
  }

  vpc_config = null

  log_group_name        = "/lambda/${var.sentry_function_name}/${local.shard_id}"
  log_retention_in_days = 7
}
