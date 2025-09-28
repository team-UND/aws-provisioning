output "aws_db_instance_region" {
  description = "value"
  value       = module.mysql.aws_db_instance_region
}

output "aws_db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = module.mysql.aws_db_instance_arn
}

output "aws_db_instance_resource_id" {
  description = "The resource ID of the RDS instance"
  value       = module.mysql.aws_db_instance_resource_id
}

output "aws_db_instance_address" {
  description = "The hostname of the RDS instance"
  value       = module.mysql.aws_db_instance_address
}

output "aws_db_instance_username" {
  description = "The master username for the RDS instance"
  value       = module.mysql.aws_db_instance_username
}

output "aws_security_group_id" {
  description = "The ID of the security group for the RDS"
  value       = module.mysql.aws_security_group_id
}

output "port" {
  description = "The port the DB is listening on"
  value       = module.mysql.port
}
