# In awsvpc mode, traffic from the ALB goes to the Task's ENI, not the instance
# This SG allows ingress from the ALB to the Tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "tasks-sg-${var.service_name}-${var.vpc_name}"
  description = "Allow inbound traffic from ALB to ECS Tasks"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.service_name}-${var.vpc_name}-tasks-sg"
  }
}

# Allow TCP traffic from the ALB to the application container port
resource "aws_vpc_security_group_ingress_rule" "tasks_alb_app_ing" {
  security_group_id            = aws_security_group.ecs_tasks.id
  from_port                    = var.service_port
  to_port                      = var.service_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.alb_security_group_id
  description                  = "Allow app traffic from the external ALB"
}

# Allow TCP traffic from the ALB for health checks
resource "aws_vpc_security_group_ingress_rule" "tasks_alb_app_health_check_ing" {
  security_group_id            = aws_security_group.ecs_tasks.id
  from_port                    = var.health_check_port
  to_port                      = var.health_check_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.alb_security_group_id
  description                  = "Allow health check traffic from the external ALB"
}

resource "aws_vpc_security_group_egress_rule" "tasks_eg" {
  security_group_id = aws_security_group.ecs_tasks.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# External LB target group
resource "aws_lb_target_group" "default" {
  name                 = "tg-${var.service_name}-${var.shard_id}"
  vpc_id               = var.vpc_id
  protocol             = "HTTP"
  target_type          = "ip"
  port                 = var.service_port
  slow_start           = var.lb_variables.target_group_slow_start[var.shard_id]
  deregistration_delay = var.lb_variables.target_group_deregistration_delay[var.shard_id]

  # Change the health check setting
  health_check {
    interval            = 15
    protocol            = "HTTP"
    port                = var.health_check_port
    path                = var.health_check_path
    timeout             = 3
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = var.lb_variables.external_lb_tg.tags[var.shard_id]
}

# Application-specific Listener Rule
resource "aws_lb_listener_rule" "default" {
  listener_arn = var.alb_https_listener_arn
  priority     = var.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }

  condition {
    host_header {
      values = [var.domain_name]
    }
  }
}

# Application-specific DNS Record
resource "aws_route53_record" "default" {
  zone_id        = var.route53_external_zone_id
  name           = var.domain_name
  type           = "A"
  set_identifier = var.aws_region

  latency_routing_policy {
    region = var.aws_region
  }

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# ECS Application Logic (Task Definition, Service)
resource "aws_ecs_task_definition" "default" {
  family                   = "task-${var.service_name}-${var.vpc_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory_hard_limit
  execution_role_arn       = var.ecs_task_execution_role_arn

  container_definitions = var.container_definitions_json
}

# Application-specific ECS Service
resource "aws_ecs_service" "default" {
  name                              = "service-${var.service_name}-${var.vpc_name}"
  cluster                           = var.ecs_cluster_id
  task_definition                   = aws_ecs_task_definition.default.arn
  desired_count                     = var.container_desired_capacity
  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  load_balancer {
    target_group_arn = aws_lb_target_group.default.arn
    container_name   = var.service_name
    container_port   = var.service_port
  }

  capacity_provider_strategy {
    capacity_provider = var.ecs_capacity_provider_name
    weight            = 1
  }

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  depends_on = [aws_lb_listener_rule.default]
}

# Defines the scalable target (our ECS service) and its min/max boundaries
resource "aws_appautoscaling_target" "default" {
  # The resource ID is constructed in the format: service/<cluster-name>/<service-name>
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.default.name}"
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.container_min_capacity
  max_capacity       = var.container_max_capacity
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
