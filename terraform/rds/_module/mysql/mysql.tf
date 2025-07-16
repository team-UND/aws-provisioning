resource "aws_security_group" "mysql" {
  description = "MySQL SG for ${var.shard_id}"
  name        = "mysql-sg-${var.vpc_name}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "mysql-sg-${var.vpc_name}"
  }
}

resource "aws_db_subnet_group" "mysql" {
  description = "MySQL Subnet Group for ${var.shard_id}"
  name        = "mysql-${var.shard_id}"
  subnet_ids  = var.subnet_ids

  tags = {
    Name = "mysql-${var.vpc_name}"
  }
}

resource "aws_route53_record" "mysql" {
  zone_id = var.route53_zone_id
  name    = var.subdomain_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_db_instance.mysql.address]
}

resource "aws_db_instance" "mysql" {
  identifier                 = "mysql-${var.shard_id}"
  engine                     = "mysql"
  engine_version             = var.engine_version
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  instance_class             = var.instance_class
  allocated_storage          = var.allocated_storage
  max_allocated_storage      = var.max_allocated_storage
  storage_type               = var.storage_type
  parameter_group_name       = aws_db_parameter_group.mysql.name
  vpc_security_group_ids     = [aws_security_group.mysql.id]
  db_subnet_group_name       = aws_db_subnet_group.mysql.name

  username                        = var.username
  db_name                         = var.db_name
  port                            = var.port
  manage_master_user_password     = var.manage_master_user_password
  multi_az                        = var.multi_az
  publicly_accessible             = var.publicly_accessible
  backup_retention_period         = var.backup_retention_period
  copy_tags_to_snapshot           = var.copy_tags_to_snapshot
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  skip_final_snapshot             = var.skip_final_snapshot

  tags = {
    Name = "mysql-${var.vpc_name}"
  }
}

resource "aws_db_parameter_group" "mysql" {
  description = "MySQL parameter group for ${var.shard_id}"
  name        = "mysql-${var.shard_id}"
  family      = var.family

  dynamic "parameter" {
    for_each = var.pg_variables.parameters[var.shard_id]
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }
}
