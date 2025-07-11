output "aws_lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = module.function.aws_lambda_function_arn
}

output "aws_lambda_function_name" {
  description = "The name of the Lambda function"
  value       = module.function.aws_lambda_function_name
}

output "aws_lb_target_group_arn" {
  description = "The ARN of the target group for the Lambda function"
  value       = module.function.aws_lb_target_group_arn
}

output "domain_name" {
  description = "The domain name for the Lambda function"
  value       = module.function.domain_name
}
