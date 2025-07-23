data "aws_acm_certificate" "default" {
  domain   = "*.${var.domain_name}"
  statuses = ["ISSUED"]
}

# Security Group for External LB
resource "aws_security_group" "default" {
  description = "External LB SG for ${var.shard_id}"
  name        = "external-lb-sg-${var.vpc_name}"
  vpc_id      = var.vpc_id

  tags = var.sg_variables.external.tags[var.shard_id]
}

resource "aws_vpc_security_group_ingress_rule" "http_lb" {
  for_each = var.lb_ingress_cidrs

  description       = "Allow HTTP traffic from ${each.key} to the LB"
  security_group_id = aws_security_group.default.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "https_lb" {
  for_each = var.lb_ingress_cidrs

  description       = "Allow HTTPS traffic from ${each.key} to the LB"
  security_group_id = aws_security_group.default.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_egress_rule" "lb" {
  description       = "Allow traffic from the LB"
  security_group_id = aws_security_group.default.id
  ip_protocol       = "-1"
  cidr_ipv4         = var.lb_egress_cidr
}

# External LB
resource "aws_lb" "default" {
  name               = "external-lb-${var.shard_id}"
  internal           = false
  load_balancer_type = var.lb_type
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.default.id]

  tags = var.lb_variables.external.tags[var.shard_id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.default.arn
  port              = "80"
  protocol          = "HTTP"

  # This is for redirect 80
  # This means that it will only allow HTTPS(443) traffic
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

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.default.arn
  port              = "443"
  protocol          = "HTTPS"

  # If you want to use HTTPS, then you need to add certificate_arn here
  certificate_arn = data.aws_acm_certificate.default.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_route53_record" "default" {
  zone_id        = var.route53_zone_id
  name           = var.subdomain_name
  type           = "A"
  set_identifier = var.aws_region

  latency_routing_policy {
    region = var.aws_region
  }

  alias {
    name                   = aws_lb.default.dns_name
    zone_id                = aws_lb.default.zone_id
    evaluate_target_health = true
  }
}
