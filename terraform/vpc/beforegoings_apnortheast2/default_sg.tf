# Default security group
# This is the security group that most of instances should have
resource "aws_security_group" "default" {
  description = "Default SG for ${var.vpc_name}"
  name        = "default-sg-${var.vpc_name}"
  vpc_id      = aws_vpc.default.id

  tags = {
    Name = "default-sg-${var.vpc_name}"
  }
}

resource "aws_vpc_security_group_egress_rule" "default_http" {
  description       = "Allow HTTP traffic from the default security group to anywhere"
  security_group_id = aws_security_group.default.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "default_https" {
  description       = "Allow HTTPS traffic from the default security group to anywhere"
  security_group_id = aws_security_group.default.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}
