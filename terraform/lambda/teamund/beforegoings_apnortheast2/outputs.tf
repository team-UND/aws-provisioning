output "authorizer_lambda_function_arn" {
  description = "The ARN of the Authorizer Lambda function"
  value       = module.authorizer.aws_lambda_function_arn
}

output "authorizer_lambda_function_invoke_arn" {
  description = "The invocation ARN of the Authorizer Lambda function for API Gateway"
  value       = module.authorizer.aws_lambda_function_invoke_arn
}

output "origin_verify_header_name" {
  description = "The name of the custom header used for origin verification"
  value       = local.origin_verify_header_name
}

output "sentry_lambda_function_arn" {
  description = "The ARN of the Sentry Lambda function"
  value       = module.sentry.aws_lambda_function_arn
}
