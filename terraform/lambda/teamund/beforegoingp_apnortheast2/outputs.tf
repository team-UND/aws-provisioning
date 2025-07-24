output "sentry_lambda_function_arn" {
  description = "ARN of the Sentry Lambda function"
  value       = module.sentry.aws_lambda_function_arn
}
