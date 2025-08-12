output "aws_security_group_vpclink_id" {
  description = "The ID of the security group for the VPC Link"
  value       = aws_security_group.vpclink.id
}

output "aws_apigatewayv2_api_id" {
  description = "The ID of the API Gateway V2 HTTP API"
  value       = aws_apigatewayv2_api.default.id
}

output "aws_apigatewayv2_api_endpoint" {
  description = "The endpoint of the API Gateway to be used as an origin for CloudFront"
  value       = aws_apigatewayv2_api.default.api_endpoint
}

output "aws_apigatewayv2_stage_name" {
  description = "The name of the API Gateway stage"
  value       = aws_apigatewayv2_stage.default.name
}

output "aws_apigatewayv2_api_execution_arn" {
  description = "The execution ARN of the API Gateway V2 HTTP API"
  value       = aws_apigatewayv2_api.default.execution_arn
}

output "aws_apigatewayv2_api_endpoint" {
  description = "The invoke URL of the API Gateway V2 HTTP API"
  value       = aws_apigatewayv2_api.default.api_endpoint
}
