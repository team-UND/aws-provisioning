# Data Sources
data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

# Networking & Security (ALB, Security Groups)
resource "aws_security_group" "external_lb" {
  name        = "ext-lb-sg-${var.vpc_name}"
  description = "${var.vpc_name} external LB SG"
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

# Security group for EC2 instances (Capacity Providers)
resource "aws_security_group" "ec2" {
  name        = "ec2-sg-${var.vpc_name}"
  description = "${var.vpc_name} instance security group"
  vpc_id      = var.vpc_id

  tags = var.sg_variables.ec2.tags[var.shard_id]
}

resource "aws_vpc_security_group_egress_rule" "ec2_eg" {
  security_group_id = aws_security_group.ec2.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# External ALB
resource "aws_lb" "external" {
  name     = "ext-lb-${var.shard_id}"
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
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

# ECS Cluster & Compute Capacity (EC2 ASG)
resource "aws_ecs_cluster" "default" {
  name = "ecs-cluster-${var.vpc_name}"
}

resource "aws_launch_template" "lt" {
  name_prefix   = "lt-${var.vpc_name}"
  image_id      = data.aws_ssm_parameter.ecs_optimized_ami.value
  instance_type = var.instance_type
  key_name      = var.private_ec2_key_name

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "ECS_CLUSTER=${aws_ecs_cluster.default.name}" > /etc/ecs/ecs.config
  EOF
  )

  vpc_security_group_ids = [aws_security_group.ec2.id, var.bastion_aware_sg]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "lt-${var.vpc_name}"
    }
  }
}

resource "aws_autoscaling_group" "default" {
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  min_size            = var.ec2_min_size
  max_size            = var.ec2_max_size
  desired_capacity    = var.ec2_desired_capacity
  vpc_zone_identifier = var.private_subnet_ids

  tag {
    key                 = "Name"
    value               = "asg-${var.vpc_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Monitoring"
    value               = "enabled"
    propagate_at_launch = true
  }
}
