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

  logging_config {
    log_group  = aws_cloudwatch_log_group.default.name
    log_format = "Text"
  }

  tags = {
    Name        = "${var.function_name}-${var.shard_id}"
    Environment = var.billing_tag
  }
}

# Listener rule for the function
resource "aws_lb_listener_rule" "default" {
  listener_arn = var.lb_https_listener_arn
  priority     = var.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }

  condition {
    host_header {
      values = [var.domain_name]
    }
  }
}

resource "aws_lambda_permission" "lb" {
  statement_id  = "AllowExecutionFromLB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.default.arn
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.default.arn
}

resource "aws_lb_target_group" "default" {
  name        = "tg-${aws_lambda_function.default.function_name}"
  target_type = "lambda"
}

resource "aws_lb_target_group_attachment" "default" {
  target_group_arn = aws_lb_target_group.default.arn
  target_id        = aws_lambda_function.default.arn

  depends_on = [aws_lambda_permission.lb]
}

resource "aws_route53_record" "default" {
  zone_id        = var.route53_zone_id
  name           = var.domain_name
  type           = "A"
  set_identifier = var.aws_region

  latency_routing_policy {
    region = var.aws_region
  }

  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_cloudwatch_log_group" "default" {
  name              = var.log_group_name
  retention_in_days = var.log_retention_in_days
}
