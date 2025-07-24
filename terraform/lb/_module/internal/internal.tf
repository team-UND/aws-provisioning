# Security Group for Internal LB
resource "aws_security_group" "default" {
  description = "Internal LB SG for ${var.shard_id}"
  name        = "int-lb-sg-${var.vpc_name}"
  vpc_id      = var.vpc_id

  tags = var.sg_variables.internal.tags[var.shard_id]
}

resource "aws_vpc_security_group_egress_rule" "lb" {
  description       = "Allow traffic from the LB"
  security_group_id = aws_security_group.default.id
  ip_protocol       = "-1"
  cidr_ipv4         = var.lb_egress_cidr
}

# Internal LB
resource "aws_lb" "default" {
  name               = "int-lb-${var.shard_id}"
  internal           = true
  load_balancer_type = var.lb_type
  subnets            = var.private_subnet_ids
  security_groups    = [aws_security_group.default.id]

  tags = var.lb_variables.internal.tags[var.shard_id]
}

# For security, the HTTP listener should not be used
# Listener for HTTP service
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.default.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}
