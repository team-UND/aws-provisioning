output "aws_db_master_user_secret_arn" {
  value = aws_db_instance.beforegoingd_mysql.master_user_secret[0].secret_arn
}
