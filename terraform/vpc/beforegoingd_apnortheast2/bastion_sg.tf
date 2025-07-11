# Security group to the bastion server
resource "aws_security_group" "bastion" {
  name        = "bastion-${var.vpc_name}"
  description = "Allow ssh access to the bastion server"
  vpc_id      = aws_vpc.default.id

  tags = {
    Name = "bastionsg-${var.vpc_name}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  for_each          = var.home_ips
  security_group_id = aws_security_group.bastion.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value

  tags = {
    Name = each.key
    IP   = each.value
  }
}

resource "aws_vpc_security_group_egress_rule" "bastion" {
  security_group_id = aws_security_group.bastion.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Security group from the bastion server
# This will be attached to the private instance which user wants to access through bastion host
resource "aws_security_group" "bastion_aware" {
  name        = "bastion-aware-${var.vpc_name}"
  description = "Allows ssh access from the bastion server"
  vpc_id      = aws_vpc.default.id

  tags = {
    Name = "bastion-aware-${var.vpc_name}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_aware_ssh" {
  security_group_id            = aws_security_group.bastion_aware.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.bastion.id
}
