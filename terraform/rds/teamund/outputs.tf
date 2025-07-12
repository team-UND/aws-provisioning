output "db_master_user_secret_arn" {
  description = "The ARN of the secret containing the master user password"
  value       = module.mysql.db_master_user_secret_arn
}
