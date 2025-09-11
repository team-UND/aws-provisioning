output "aws_db_master_user_secret_arn" {
  description = "The ARN of the secret containing the master user password"
  value       = module.mysql.aws_db_master_user_secret_arn
}

output "aws_security_group_id" {
  description = "The ID of the security group for the RDS"
  value       = module.mysql.aws_security_group_id
}

output "port" {
  description = "The port the DB is listening on"
  value       = module.mysql.port
}
