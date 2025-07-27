resource "aws_ecs_service" "default" {
  name                              = "service-${var.service_name}-${var.vpc_name}"
  cluster                           = var.ecs_cluster_id
  task_definition                   = aws_ecs_task_definition.default.arn
  desired_count                     = var.container_desired_capacity
  health_check_grace_period_seconds = var.health_check_grace_period_seconds
  enable_execute_command            = var.enable_execute_command
  enable_ecs_managed_tags           = true

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

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
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.default.id]
  }

  deployment_controller {
    type = var.deployment_controller_type
  }

  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  depends_on = [aws_lb_listener_rule.default]
}

resource "aws_appautoscaling_target" "default" {
  # The resource ID is constructed in the format: service/<cluster-name>/<service-name>
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.default.name}"
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.container_min_capacity
  max_capacity       = var.container_max_capacity
}

resource "aws_appautoscaling_policy" "default" {
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

resource "aws_ecs_task_definition" "default" {
  family                   = "task-${var.service_name}-${var.vpc_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  task_role_arn            = var.ecs_task_role_arn
  execution_role_arn       = var.ecs_task_execution_role_arn

  container_definitions = var.container_definitions_json
}

resource "aws_security_group" "default" {
  description = "ECS Task SG for ${var.shard_id}"
  name        = "task-sg-${var.service_name}-${var.vpc_name}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "task-sg-${var.service_name}-${var.vpc_name}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "lb_task_app" {
  description                  = "Allow traffic from the LB to the ECS Task application"
  security_group_id            = aws_security_group.default.id
  from_port                    = var.service_port
  to_port                      = var.service_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.lb_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "lb_task_health_check" {
  description                  = "Allow traffic from the LB to the ECS Task health check"
  security_group_id            = aws_security_group.default.id
  from_port                    = var.health_check_port
  to_port                      = var.health_check_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.lb_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "task" {
  description       = "Allow traffic from the ECS Task"
  security_group_id = aws_security_group.default.id
  ip_protocol       = "-1"
  cidr_ipv4         = var.task_egress_cidr
}

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
    protocol            = "HTTP"
    path                = var.health_check_path
    port                = var.health_check_port
    matcher             = "200"
    interval            = var.lb_variables.health_check.interval[var.shard_id]
    timeout             = var.lb_variables.health_check.timeout[var.shard_id]
    healthy_threshold   = var.lb_variables.health_check.healthy_threshold[var.shard_id]
    unhealthy_threshold = var.lb_variables.health_check.unhealthy_threshold[var.shard_id]
  }

  tags = var.lb_variables.lb_tg.tags[var.shard_id]
}

resource "aws_lb_listener_rule" "default" {
  listener_arn = var.lb_http_listener_arn
  priority     = var.listener_rule_priority

  condition {
    path_pattern {
      values = var.listener_rule_path_patterns
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}

resource "aws_cloudwatch_log_group" "default" {
  name              = var.log_group_name
  retention_in_days = var.log_retention_in_days
}
