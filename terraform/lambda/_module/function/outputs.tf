output "aws_lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.default.arn
}

output "aws_lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.default.function_name
}

output "aws_lb_target_group_arn" {
  description = "The ARN of the target group for the Lambda function"
  value       = aws_lb_target_group.default.arn
}

output "domain_name" {
  description = "The domain name configured for the function"
  value       = var.domain_name
}
