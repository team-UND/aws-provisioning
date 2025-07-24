output "sentry_lambda_function_arn" {
  description = "The ARN of the Sentry Lambda function"
  value       = module.sentry.aws_lambda_function_arn
}

output "authorizer_lambda_function_arn" {
  description = "The ARN of the Authorizer Lambda function"
  value       = module.authorizer.aws_lambda_function_arn
}
