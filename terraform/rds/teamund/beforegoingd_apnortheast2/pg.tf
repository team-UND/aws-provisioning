resource "aws_db_parameter_group" "mysql_pg" {
  name        = "mysql-${data.terraform_remote_state.vpc.outputs.shard_id}"
  family      = "mysql8.0"
  description = "MySQL parameter group"

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }
}

variable "db_parameters" {
  type = list(any)
  default = [
    {
      name         = "time_zone"
      value        = "Asia/Seoul"
      apply_method = "pending-reboot"
    },
    {
      name         = "character_set_server"
      value        = "utf8mb4"
      apply_method = "pending-reboot"
    },
    {
      name         = "wait_timeout"
      value        = "1200"
      apply_method = "immediate"
    }
  ]
}
