data "aws_secretsmanager_secret" "origin_verify" {
  name = "stg/origin-verify/cloudfront"
}

locals {
  origin_verify_header_name = "X-Origin-Verify"
}

module "authorizer" {
  source = "../../_module/function"

  aws_region  = data.terraform_remote_state.vpc.outputs.aws_region
  vpc_name    = local.vpc_name
  shard_id    = local.shard_id
  billing_tag = data.terraform_remote_state.vpc.outputs.billing_tag

  source_file_path = "${path.module}/${var.authorizer_function_name}.py"
  output_path      = "${path.module}/${var.authorizer_function_name}.zip"

  function_name = var.authorizer_function_name
  handler       = "${var.authorizer_function_name}.lambda_handler"
  role          = data.terraform_remote_state.iam.outputs.aws_iam_role_authorizer_arn

  runtime     = var.authorizer_runtime
  timeout     = var.authorizer_timeout
  memory_size = var.authorizer_memory_size

  env_variables = {
    ORIGIN_VERIFY_SECRET_ARN  = data.aws_secretsmanager_secret.origin_verify.arn
    ORIGIN_VERIFY_HEADER_NAME = local.origin_verify_header_name
  }

  vpc_config = null

  log_group_name        = "/lambda/${var.authorizer_function_name}/${local.shard_id}"
  log_retention_in_days = 7
}
