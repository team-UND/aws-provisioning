resource "aws_apprunner_service" "default" {
  service_name = "ar-${var.service_name}-${var.vpc_name}"

  source_configuration {
    authentication_configuration {
      access_role_arn = var.access_role_arn
    }

    image_repository {
      image_identifier      = "${var.image_url}:${var.image_tag}"
      image_repository_type = var.image_repository_type

      image_configuration {
        port                          = var.container_port
        runtime_environment_variables = var.environment_variables
        runtime_environment_secrets   = var.environment_secrets
      }
    }
    auto_deployments_enabled = var.auto_deploy
  }

  instance_configuration {
    instance_role_arn = var.instance_role_arn
    cpu               = var.cpu
    memory            = var.memory
  }

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.default.arn

  network_configuration {
    ingress_configuration {
      is_publicly_accessible = var.is_publicly_accessible
    }

    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.default.arn
    }
  }

  health_check_configuration {
    protocol            = var.lb_variables.health_check.protocol
    path                = var.lb_variables.health_check.path
    interval            = var.lb_variables.health_check.interval
    timeout             = var.lb_variables.health_check.timeout
    healthy_threshold   = var.lb_variables.health_check.healthy_threshold
    unhealthy_threshold = var.lb_variables.health_check.unhealthy_threshold
  }

  observability_configuration {
    observability_configuration_arn = var.enable_observability ? aws_apprunner_observability_configuration.default[0].arn : null
    observability_enabled           = var.enable_observability
  }

  tags = {
    Name = "${var.service_name}-${var.vpc_name}"
  }
}

resource "aws_security_group" "default" {
  description = "App Runner SG for ${var.shard_id}"
  name        = "ar-sg-${var.vpc_name}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "ar-sg-${var.vpc_name}"
  }
}

resource "aws_vpc_security_group_egress_rule" "ap" {
  description       = "Allow traffic from the App Runner"
  security_group_id = aws_security_group.default.id
  ip_protocol       = "-1"
  cidr_ipv4         = var.ar_egress_cidr
}

resource "aws_apprunner_auto_scaling_configuration_version" "default" {
  auto_scaling_configuration_name = "${var.service_name}-${var.vpc_name}"

  min_size        = var.autoscaling_min_size
  max_size        = var.autoscaling_max_size
  max_concurrency = var.autoscaling_max_concurrency

  tags = {
    Name = "${var.service_name}-ar-as-${var.vpc_name}"
  }
}

resource "aws_apprunner_vpc_connector" "default" {
  vpc_connector_name = "${var.service_name}-${var.vpc_name}"
  subnets            = var.subnet_ids
  security_groups    = [aws_security_group.default.id]
}

resource "aws_apprunner_custom_domain_association" "default" {
  service_arn = aws_apprunner_service.default.arn

  domain_name          = "${var.subdomain_name}.${var.domain_name}"
  enable_www_subdomain = var.enable_www_subdomain
}

resource "aws_apprunner_observability_configuration" "default" {
  count = var.enable_observability ? 1 : 0

  observability_configuration_name = "obs-config-${var.service_name}"

  trace_configuration {
    vendor = "AWSXRAY"
  }

  tags = {
    Name = "${var.service_name}-obs-config-${var.vpc_name}"
  }
}
