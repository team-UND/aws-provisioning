module "mysql" {
  source = "../../_module/mysql"

  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_name   = data.terraform_remote_state.vpc.outputs.vpc_name
  shard_id   = data.terraform_remote_state.vpc.outputs.shard_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_db_subnet_ids

  route53_zone_id = data.terraform_remote_state.vpc.outputs.route53_internal_zone_id
  subdomain_name  = "mysql"
  port            = 3006

  engine_version             = "8.0"
  auto_minor_version_upgrade = true
  instance_class             = "db.t3.micro"
  allocated_storage          = 20
  max_allocated_storage      = 0
  storage_type               = "gp2"

  username                        = "team_UND_Beforegoing_stg_admin"
  db_name                         = "beforegoings"
  manage_master_user_password     = true
  multi_az                        = false
  publicly_accessible             = false
  backup_retention_period         = 7
  copy_tags_to_snapshot           = true
  enabled_cloudwatch_logs_exports = ["general"]
  skip_final_snapshot             = true
  family                          = "mysql8.0"
  pg_variables                    = var.pg_variables
}
