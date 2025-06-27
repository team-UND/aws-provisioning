output "aws_lambda_function_codedeploy_notification_function_name" {
  value = aws_lambda_function.codedeploy_notification.function_name
}

output "aws_lambda_function_codedeploy_notification_arn" {
  value = aws_lambda_function.codedeploy_notification.arn
}

output "aws_lambda_function_sentry_notification_invoke_arn" {
  value = aws_lambda_function.sentry_notification.invoke_arn
}

output "aws_lambda_function_sentry_notification_arn" {
  value = aws_lambda_function.sentry_notification.arn
}
