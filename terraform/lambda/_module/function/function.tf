data "archive_file" "lambda_function_zip" {
  type        = "zip"
  source_file = var.source_file_path
  output_path = var.output_path
}

resource "aws_lambda_function" "default" {
  filename         = data.archive_file.lambda_function_zip.output_path
  source_code_hash = data.archive_file.lambda_function_zip.output_base64sha256

  function_name = "${var.function_name}-${var.shard_id}"
  handler       = var.handler
  role          = var.role

  runtime     = var.runtime
  timeout     = var.timeout
  memory_size = var.memory_size

  environment {
    variables = var.env_variables
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [1] : []

    content {
      subnet_ids         = var.vpc_config.subnet_ids
      security_group_ids = var.vpc_config.security_group_ids
    }
  }

  logging_config {
    log_group  = aws_cloudwatch_log_group.default.name
    log_format = "Text"
  }

  tags = {
    Name        = "lambda-${var.function_name}-${var.vpc_name}"
    Environment = var.billing_tag
  }
}

resource "aws_cloudwatch_log_group" "default" {
  name              = var.log_group_name
  retention_in_days = var.log_retention_in_days
}
