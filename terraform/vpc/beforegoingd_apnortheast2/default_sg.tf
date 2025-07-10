# Default security group
# This is the security group that most of instances should have
resource "aws_security_group" "default" {
  name        = "default-${var.vpc_name}"
  description = "default group for ${var.vpc_name}"
  vpc_id      = aws_vpc.default.id

  tags = {
    Name = "defaultsg-${var.vpc_name}"
  }
}

resource "aws_vpc_security_group_egress_rule" "default_http_eg" {
  security_group_id = aws_security_group.default.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "http any outbound"
}

resource "aws_vpc_security_group_egress_rule" "default_https_eg" {
  security_group_id = aws_security_group.default.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "https any outbound"
}

# Home security group
# This will be usually attached to the web server that users in the office should access through browser
# This is used for all users in the company to access to the resources in the office or home
resource "aws_security_group" "home" {
  name        = "home"
  description = "Home security group for ${var.vpc_name}"
  vpc_id      = aws_vpc.default.id

  tags = {
    Name = "homesg-${var.vpc_name}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "home_ssh_ing" {
  for_each          = var.home_ips
  security_group_id = aws_security_group.home.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value

  tags = {
    Name = each.key
    IP   = each.value
  }
}

resource "aws_vpc_security_group_ingress_rule" "home_https_ing" {
  for_each          = var.home_ips
  security_group_id = aws_security_group.home.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value

  tags = {
    Name = each.key
    IP   = each.value
  }
}
