# Security group for external LB
# Only allow access from IPs or SGs you specifiy in ext_lb_ingress_cidrs variables
resource "aws_security_group" "external_lb" {
  name        = "${var.service_name}-${var.vpc_name}-ext"
  description = "${var.service_name} external LB SG"
  vpc_id      = var.vpc_id

  tags = var.sg_variables.external_lb.tags[var.shard_id]
}

resource "aws_vpc_security_group_ingress_rule" "external_lb_http_ing" {
  security_group_id = aws_security_group.external_lb.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = var.ext_lb_ingress_cidrs
  description       = "External service http port"
}

resource "aws_vpc_security_group_ingress_rule" "external_lb_https_ing" {
  security_group_id = aws_security_group.external_lb.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = var.ext_lb_ingress_cidrs
  description       = "External service https port"
}

resource "aws_vpc_security_group_egress_rule" "external_lb_eg" {
  security_group_id = aws_security_group.external_lb.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Internal outbound any traffic"
}

# Security group for EC2
resource "aws_security_group" "ec2" {
  name        = "${var.service_name}-${var.vpc_name}"
  description = "${var.service_name} instance security group"
  vpc_id      = var.vpc_id

  tags = {
    Name  = "${var.service_name}-${var.vpc_name}-sg"
    app   = var.service_name
    stack = var.vpc_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_ing" {
  security_group_id            = aws_security_group.ec2.id
  from_port                    = var.service_port
  to_port                      = var.service_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.external_lb.id

  description = "Port open for ${var.service_name}"
}

resource "aws_vpc_security_group_ingress_rule" "ec2_healthcheck_ing" {
  security_group_id            = aws_security_group.ec2.id
  from_port                    = var.healthcheck_port
  to_port                      = var.healthcheck_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.external_lb.id

  description = "Port open for ${var.service_name}"
}

resource "aws_vpc_security_group_ingress_rule" "ec2_observer_ing" {
  security_group_id            = aws_security_group.ec2.id
  from_port                    = var.observer_port
  to_port                      = var.observer_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.observer_sg

  description = "Port open for ${var.service_name}"
}

resource "aws_vpc_security_group_egress_rule" "ec2_eg" {
  security_group_id = aws_security_group.ec2.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# External ALB
resource "aws_lb" "external" {
  name     = "${var.service_name}-${var.shard_id}-ext"
  subnets  = var.public_subnet_ids
  internal = false

  # For external LB,
  # Home SG (Including office IPs) could be added if this services is internal service
  security_groups = [
    aws_security_group.external_lb.id,
    var.home_sg
  ]

  # For HTTP service, application LB is recommended
  load_balancer_type = "application"

  tags = var.lb_variables.external_lb.tags[var.shard_id]
}

# External LB target group
resource "aws_lb_target_group" "external" {
  name                 = "${var.service_name}-${var.shard_id}-ext"
  port                 = var.service_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  slow_start           = var.lb_variables.target_group_slow_start[var.shard_id]
  deregistration_delay = var.lb_variables.target_group_deregistration_delay[var.shard_id]

  # Change the health check setting
  health_check {
    interval            = 15
    port                = var.healthcheck_port
    path                = var.healthcheck_path
    timeout             = 3
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = var.lb_variables.external_lb_tg.tags[var.shard_id]
}

# Listener for HTTP service
resource "aws_lb_listener" "external_http" {
  load_balancer_arn = aws_lb.external.arn
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
resource "aws_lb_listener" "external_https" {
  load_balancer_arn = aws_lb.external.arn
  port              = "443"
  protocol          = "HTTPS"

  # If you want to use HTTPS, you need to add certificate_arn here
  certificate_arn = var.acm_external_ssl_certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.external.arn
    type             = "forward"
  }
}

# Route53 record
resource "aws_route53_record" "external_dns" {
  zone_id        = var.route53_external_zone_id
  name           = var.domain_name
  type           = "A"
  set_identifier = var.aws_region

  latency_routing_policy {
    region = var.aws_region
  }

  alias {
    name                   = aws_lb.external.dns_name
    zone_id                = aws_lb.external.zone_id
    evaluate_target_health = true
  }
}

# ASG
resource "aws_launch_template" "lt" {
  name_prefix   = "${var.service_name}-${var.vpc_name}-lt"
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name      = var.private_ec2_key_name

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }
  user_data = base64encode(templatefile(var.user_data_path, { aws_region = var.aws_region }))

  vpc_security_group_ids = [aws_security_group.ec2.id, var.bastion_aware_sg]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.service_name}-${var.vpc_name}-lt"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.private_subnet_ids

  target_group_arns = [aws_lb_target_group.external.arn]

  tag {
    key                 = "Name"
    value               = "${var.service_name}-${var.vpc_name}-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "Monitoring"
    value               = "enabled"
    propagate_at_launch = true
  }
}
