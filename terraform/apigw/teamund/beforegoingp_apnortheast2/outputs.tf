output "aws_apigatewayv2_api_id" {
  description = "The ID of the API Gateway V2 HTTP API"
  value       = module.http.aws_apigatewayv2_api_id
}

output "aws_apigatewayv2_api_api_endpoint" {
  description = "The endpoint of the API Gateway to be used as an origin for CloudFront"
  value       = module.http.aws_apigatewayv2_api_api_endpoint
}

output "aws_apigatewayv2_stage_name" {
  description = "The name of the API Gateway stage"
  value       = module.http.aws_apigatewayv2_stage_name
}
