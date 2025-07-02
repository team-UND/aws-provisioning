resource "aws_db_subnet_group" "beforegoingd_mysql" {
  name       = "mysql-${data.terraform_remote_state.vpc.outputs.shard_id}"
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_db_subnet_ids

  tags = {
    Name = "mysql-${data.terraform_remote_state.vpc.outputs.shard_id}"
  }
}

resource "aws_route53_record" "beforegoingd_rds" {
  zone_id = data.terraform_remote_state.vpc.outputs.route53_internal_zone_id
  name    = var.internal_domain_name
  type    = "CNAME"
  ttl     = 60
  records = [aws_db_instance.beforegoingd_mysql.address]
}

resource "aws_db_instance" "beforegoingd_mysql" {
  identifier                 = "mysql-${data.terraform_remote_state.vpc.outputs.shard_id}"
  engine                     = "mysql"
  engine_version             = "8.0"
  auto_minor_version_upgrade = true
  instance_class             = "db.t3.micro"
  allocated_storage          = 20
  max_allocated_storage      = 0
  storage_type               = "gp2"
  parameter_group_name       = aws_db_parameter_group.beforegoingd_mysql_pg.name
  vpc_security_group_ids     = [aws_security_group.beforegoingd_mysql.id]
  db_subnet_group_name       = aws_db_subnet_group.beforegoingd_mysql.name

  username                        = var.username
  db_name                         = var.db_name
  port                            = var.port
  manage_master_user_password     = true
  multi_az                        = false
  publicly_accessible             = false
  backup_retention_period         = 7
  copy_tags_to_snapshot           = true
  enabled_cloudwatch_logs_exports = ["general"]
  skip_final_snapshot             = true

  tags = {
    Name = "mysql-${data.terraform_remote_state.vpc.outputs.shard_id}"
  }
}
