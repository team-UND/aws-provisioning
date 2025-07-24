output "aws_lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.default.arn
}

output "aws_lambda_function_invoke_arn" {
  description = "The invocation ARN of the Lambda function"
  value       = aws_lambda_function.default.invoke_arn
}
