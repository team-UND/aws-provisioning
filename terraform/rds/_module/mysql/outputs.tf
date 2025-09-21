output "aws_db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.mysql.arn
}

output "aws_db_instance_username" {
  description = "The master username for the RDS instance"
  value       = aws_db_instance.mysql.username
}

output "aws_db_master_user_secret_arn" {
  description = "The ARN of the secret containing the master user password"
  value       = aws_db_instance.mysql.master_user_secret[0].secret_arn
}

output "aws_security_group_id" {
  description = "The ID of the security group for the RDS"
  value       = aws_security_group.mysql.id
}

output "port" {
  description = "The port the DB is listening on"
  value       = aws_db_instance.mysql.port
}
