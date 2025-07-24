resource "aws_security_group" "vpclink" {
  description = "VPC Link SG for ${var.shard_id}"
  name        = "vpclink-sg-${var.vpc_name}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "vpclink-sg-${var.vpc_name}"
  }
}

resource "aws_vpc_security_group_egress_rule" "vpclink_http" {
  description                  = "Allow HTTP traffic from the VPC Link"
  security_group_id            = aws_security_group.vpclink.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "-1"
  referenced_security_group_id = var.lb_security_group_id
}

resource "aws_apigatewayv2_vpc_link" "default" {
  name               = "http-apigw-vpclink-${var.vpc_name}"
  security_group_ids = [aws_security_group.vpclink.id]
  subnet_ids         = var.private_subnet_ids

  tags = {
    Name = "http-apigw-vpclink-${var.vpc_name}"
  }
}

resource "aws_apigatewayv2_api" "default" {
  description   = "HTTP API GW for ${var.shard_id}"
  name          = "http-apigw-${var.vpc_name}"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = var.cors_allow_origins
    allow_methods = var.cors_allow_methods
    allow_headers = var.cors_allow_headers
  }
}

resource "aws_apigatewayv2_integration" "lambdas" {
  for_each = var.lambda_integrations

  description            = "Lambda Integration"
  api_id                 = aws_apigatewayv2_api.default.id
  integration_type       = "AWS_PROXY" # For Lambda
  integration_uri        = each.value.arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "lb" {
  description            = "Load Balancer Integration"
  api_id                 = aws_apigatewayv2_api.default.id
  integration_type       = "HTTP_PROXY"
  integration_uri        = var.lb_listener_arn
  integration_method     = "ANY"
  connection_type        = "VPC_LINK" # For LB
  connection_id          = aws_apigatewayv2_vpc_link.default.id
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "lambdas" {
  for_each = var.lambda_integrations

  api_id    = aws_apigatewayv2_api.default.id
  route_key = each.value.route_key
  target    = "integrations/${aws_apigatewayv2_integration.lambdas[each.key].id}"
}

resource "aws_apigatewayv2_route" "lb" {
  api_id    = aws_apigatewayv2_api.default.id
  route_key = var.lb_route_key
  target    = "integrations/${aws_apigatewayv2_integration.lb.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  description = "Stage for the API Gateway"
  api_id      = aws_apigatewayv2_api.default.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.default.arn
    format = jsonencode({
      requestId               = "$context.requestId",
      sourceIp                = "$context.identity.sourceIp",
      requestTime             = "$context.requestTime",
      httpMethod              = "$context.httpMethod",
      path                    = "$context.path",
      status                  = "$context.status",
      responseLength          = "$context.responseLength",
      integrationErrorMessage = "$context.integrationErrorMessage",
      integrationLatency      = "$context.integration.latency",
      integrationStatus       = "$context.integration.status"
      }
    )
  }

  default_route_settings {
    throttling_burst_limit = var.throttling_burst_limit
    throttling_rate_limit  = var.throttling_rate_limit
  }
}

resource "aws_lambda_permission" "apigw" {
  for_each = var.lambda_integrations

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = each.value.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.default.execution_arn}/${aws_apigatewayv2_stage.default.name}/${each.value.route_key}"
}

# CloudWatch Log Group for API Gateway Access Logs
resource "aws_cloudwatch_log_group" "default" {
  name              = var.log_group_name
  retention_in_days = var.log_retention_in_days
}
