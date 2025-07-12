output "db_master_user_secret_arn" {
  description = "The ARN of the secret containing the master user password"
  value       = aws_db_instance.mysql.master_user_secret[0].secret_arn
}
