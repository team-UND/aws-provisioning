# Data Sources
data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

# Networking & Security (ALB, Security Groups)
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

# Security group for EC2 instances (Capacity Providers)
resource "aws_security_group" "ec2" {
  name        = "${var.service_name}-${var.vpc_name}"
  description = "${var.service_name} instance security group"
  vpc_id      = var.vpc_id

  tags = var.sg_variables.ec2.tags[var.shard_id]
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

# In awsvpc mode, traffic from the ALB goes to the Task's ENI, not the instance
# This SG allows ingress from the ALB to the Tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.service_name}-${var.vpc_name}-tasks"
  description = "Allow inbound traffic from ALB to ECS Tasks"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.service_name}-${var.vpc_name}-tasks-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "tasks_alb_ing" {
  security_group_id            = aws_security_group.ecs_tasks.id
  from_port                    = 0
  to_port                      = 0
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.external_lb.id
  description                  = "Allow all traffic from the external load balancer"
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
  vpc_id               = var.vpc_id
  protocol             = "HTTP"
  target_type          = "ip"
  port                 = var.service_port
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

# DNS
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

# ECS Cluster & Compute Capacity (EC2 ASG)
resource "aws_ecs_cluster" "default" {
  name = "ecs-cluster-${var.service_name}-${var.vpc_name}"
}

resource "aws_launch_template" "lt" {
  name_prefix   = "${var.service_name}-${var.vpc_name}-lt"
  image_id      = data.aws_ssm_parameter.ecs_optimized_ami.value
  instance_type = var.instance_type
  key_name      = var.private_ec2_key_name

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "ECS_CLUSTER=${aws_ecs_cluster.main.name}" > /etc/ecs/ecs.config

    mkdir -p /ecs
    cat <<'EOT' > /ecs/prometheus.yml
${file("${path.module}/prometheus.yml")}
EOT
  EOF
  )

  vpc_security_group_ids = [aws_security_group.ec2.id, var.bastion_aware_sg]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.service_name}-${var.vpc_name}-lt"
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
    value               = "${var.service_name}-${var.vpc_name}-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "Monitoring"
    value               = "enabled"
    propagate_at_launch = true
  }
}

# ECS Application Logic (Task Definition, Service)
resource "aws_ecs_task_definition" "default" {
  family                   = "${var.service_name}-${var.vpc_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory

  execution_role_arn = var.ecs_task_execution_role_arn

  volume {
    name      = "prometheus-config-volume"
    host_path = "/ecs/prometheus.yml"
  }

  container_definitions = templatefile("${path.module}/container-definitions.json.tftpl", {
    service_name         = var.service_name
    image_url            = var.container_image_url
    prometheus_image_url = var.prometheus_image_url
    service_port         = var.service_port
    log_group_name       = aws_cloudwatch_log_group.default.name
    aws_region           = var.aws_region
  })
}

resource "aws_ecs_service" "default" {
  name            = "${var.service_name}-${var.vpc_name}-service"
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.default.arn
  desired_count   = var.container_desired_capacity
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.external.arn
    container_name   = var.service_name
    container_port   = var.service_port
  }

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  depends_on = [aws_lb_listener.external_https, aws_autoscaling_group.default]
}

# Defines the scalable target (our ECS service) and its min/max boundaries
resource "aws_appautoscaling_target" "default" {
  # The resource ID is constructed in the format: service/<cluster-name>/<service-name>
  resource_id        = "service/${aws_ecs_cluster.default.name}/${aws_ecs_service.default.name}"
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"

  min_capacity = var.container_min_capacity
  max_capacity = var.container_max_capacity
}

# Defines the scaling policy based on a target metric (e.g., average CPU utilization)
resource "aws_appautoscaling_policy" "cpu_scaling" {
  name               = "${var.service_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.default.resource_id
  scalable_dimension = aws_appautoscaling_target.default.scalable_dimension
  service_namespace  = aws_appautoscaling_target.default.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "/ecs/${var.service_name}"
  retention_in_days = 7
}
