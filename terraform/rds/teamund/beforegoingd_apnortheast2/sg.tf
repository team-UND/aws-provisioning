resource "aws_security_group" "beforegoingd_mysql" {
  name        = "mysql-${data.terraform_remote_state.vpc.outputs.shard_id}"
  description = "beforegoing preprod mysql SG"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = {
    Name = "mysql-${data.terraform_remote_state.vpc.outputs.shard_id}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "mysql_ing" {
  security_group_id            = aws_security_group.beforegoingd_mysql.id
  from_port                    = var.port
  to_port                      = var.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = data.terraform_remote_state.server.outputs.aws_security_group_ec2_id
}
