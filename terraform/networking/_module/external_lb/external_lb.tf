# Security Group for External LB
resource "aws_security_group" "default" {
  name        = "ext-lb-sg-${var.vpc_name}"
  description = "${var.vpc_name} external LB SG"
  vpc_id      = var.vpc_id

  tags = var.sg_variables.lb.tags[var.shard_id]
}

resource "aws_vpc_security_group_ingress_rule" "lb_http" {
  security_group_id = aws_security_group.default.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = var.lb_ingress_cidrs
  description       = "External service http port"
}

resource "aws_vpc_security_group_ingress_rule" "lb_https" {
  security_group_id = aws_security_group.default.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = var.lb_ingress_cidrs
  description       = "External service https port"
}

resource "aws_vpc_security_group_egress_rule" "lb" {
  security_group_id = aws_security_group.default.id
  ip_protocol       = "-1"
  cidr_ipv4         = var.vpc_cidr_block
  description       = "Allow all outbound traffic to resources within the VPC"
}

# External LB
resource "aws_lb" "default" {
  name     = "ext-lb-${var.shard_id}"
  subnets  = var.public_subnet_ids
  internal = false

  # For external LB,
  # Home SG (Including office IPs) could be added if this services is internal service
  security_groups = [
    aws_security_group.default.id,
  ]

  # For HTTP service, application LB is recommended
  load_balancer_type = var.load_balancer_type

  tags = var.lb_variables.lb.tags[var.shard_id]
}

# Listener for HTTP service
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.default.arn
  port              = "80"
  protocol          = "HTTP"

  # This for redirecting
  # This meands that it will only allow HTTPS(443) traffic
  default_action {
    type = "redirect"

    redirect {
      port     = "443"
      protocol = "HTTPS"
      # 301 -> Permanant Movement
      status_code = "HTTP_301"
    }
  }
}

# Listener for HTTPS service
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.default.arn
  port              = "443"
  protocol          = "HTTPS"

  # If you want to use HTTPS, you need to add certificate_arn here
  certificate_arn = var.acm_external_ssl_certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}
