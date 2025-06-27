resource "aws_apigatewayv2_api" "http" {
  name          = "apigw-${data.terraform_remote_state.vpc.outputs.shard_id}"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "sentry_notification_lambda" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_uri        = data.terraform_remote_state.lambda.outputs.aws_lambda_function_sentry_notification_invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "sentry" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "POST /sentry"
  target    = "integrations/${aws_apigatewayv2_integration.sentry_notification_lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_domain_name" "external_dns" {
  domain_name = "${var.subdomain_name}.${data.terraform_remote_state.route53.outputs.aws_route53_zone_beforegoing_site_name}"

  domain_name_configuration {
    certificate_arn = var.r53_variables.preprod.star_beforegoing_site_acm_arn_apnortheast2
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_route53_record" "external_dns" {
  zone_id = var.r53_variables.preprod.beforegoing_site_zone_id
  name    = var.subdomain_name
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.external_dns.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.external_dns.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_apigatewayv2_api_mapping" "external_dns" {
  api_id      = aws_apigatewayv2_api.http.id
  domain_name = aws_apigatewayv2_domain_name.external_dns.id
  stage       = aws_apigatewayv2_stage.default.name
}

resource "aws_lambda_permission" "allow_apigw_to_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = data.terraform_remote_state.lambda.outputs.aws_lambda_function_sentry_notification_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}
