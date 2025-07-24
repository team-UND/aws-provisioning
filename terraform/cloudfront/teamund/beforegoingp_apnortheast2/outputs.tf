output "aws_secretsmanager_secret_arn" {
  description = "The ARN of the secret in Secrets Manager for origin verification"
  value       = aws_secretsmanager_secret.default.arn
}
