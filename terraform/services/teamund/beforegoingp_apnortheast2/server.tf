data "aws_secretsmanager_secret" "app_secrets" {
  name = "prod/server/springboot"
}

data "aws_secretsmanager_secret" "prometheus_secrets" {
  name = "prod/prometheus"
}

locals {
  shard_id          = data.terraform_remote_state.vpc.outputs.shard_id
  service_name      = "server"
  service_port      = 8080
  health_check_port = 10090
  actuator_path     = "/server/actuator"
  health_check_path = "${local.actuator_path}/health"
  prometheus_path   = "${local.actuator_path}/prometheus"
  log_group_name    = "/services/${local.service_name}/${local.shard_id}"

  # Define any variables needed by the container definition template here
  template_vars = {
    aws_region                  = data.terraform_remote_state.vpc.outputs.aws_region
    service_name                = local.service_name
    image_uri                   = data.terraform_remote_state.repository.outputs.aws_ecr_repository_server_build_repository_url
    image_tag                   = "bfa3302"
    container_cpu_limit         = 400
    container_memory_hard_limit = 400
    container_memory_soft_limit = 400
    max_swap                    = 2048
    swappiness                  = 80
    service_port                = local.service_port
    health_check_port           = local.health_check_port
    health_check_path           = local.health_check_path
    prometheus_path             = local.prometheus_path
    prometheus_enable           = true
    spring_profiles_active      = data.terraform_remote_state.vpc.outputs.billing_tag
    log_group_name              = local.log_group_name
    rdb_secrets_arn             = data.terraform_remote_state.mysql.outputs.aws_db_master_user_secret_arn
    app_secrets_arn             = data.aws_secretsmanager_secret.app_secrets.arn
    prometheus_secrets_arn      = data.aws_secretsmanager_secret.prometheus_secrets.arn
  }

  # Render the container definition template using the variables defined above
  container_definitions_json = templatefile("${path.module}/container-definitions.json.tftpl", local.template_vars)
}

resource "aws_vpc_security_group_ingress_rule" "task_mysql" {
  description                  = "Allow traffic from the ECS Task to the MySQL"
  security_group_id            = data.terraform_remote_state.mysql.outputs.aws_security_group_id
  from_port                    = data.terraform_remote_state.mysql.outputs.port
  to_port                      = data.terraform_remote_state.mysql.outputs.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = module.server.aws_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "task_redis" {
  description                  = "Allow traffic from the ECS Task to the Redis"
  security_group_id            = data.terraform_remote_state.redis.outputs.aws_security_group_id
  from_port                    = data.terraform_remote_state.redis.outputs.port
  to_port                      = data.terraform_remote_state.redis.outputs.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = module.server.aws_security_group_id
}

# Allow public access to the health check endpoint
# This rule has the highest priority (lowest number) to ensure it's always allowed
resource "aws_lb_listener_rule" "health_check_allow" {
  listener_arn = data.terraform_remote_state.int_lb.outputs.aws_lb_listener_http_arn
  priority     = 97

  condition {
    path_pattern {
      values = [local.health_check_path]
    }
  }

  condition {
    source_ip {
      values = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
    }
  }

  action {
    type             = "forward"
    target_group_arn = module.server.aws_lb_target_group_arn
  }
}

# Allow access to the Actuator endpoint only from the Prometheus server
# And block all other access
resource "aws_lb_listener_rule" "observability_allow" {
  listener_arn = data.terraform_remote_state.int_lb.outputs.aws_lb_listener_http_arn
  priority     = 98

  condition {
    path_pattern {
      values = [local.prometheus_path]
    }
  }

  condition {
    source_ip {
      # Allow traffic from the observability subnets where Prometheus will be running
      values = data.terraform_remote_state.vpc.outputs.private_observability_subnet_cidrs
    }
  }

  action {
    type             = "forward"
    target_group_arn = module.server.aws_lb_target_group_arn
  }
}

resource "aws_lb_listener_rule" "actuator_block" {
  listener_arn = data.terraform_remote_state.int_lb.outputs.aws_lb_listener_http_arn
  priority     = 99

  condition {
    path_pattern {
      # Block the base actuator path AND all sub-paths to secure the endpoint.
      values = [local.actuator_path, "${local.actuator_path}/*"]
    }
  }

  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Forbidden"
      status_code  = "403"
    }
  }
}

# Use module for service
module "server" {
  source = "../../_module/server"

  # Name of service
  service_name = local.service_name

  # Port for service and healthcheck
  task_egress_cidr                  = "0.0.0.0/0" # Allow traffic from the ECS task to anywhere
  service_port                      = local.service_port
  health_check_port                 = local.health_check_port
  health_check_path                 = local.health_check_path
  health_check_grace_period_seconds = 90

  # VPC Information via remote_state
  shard_id   = local.shard_id
  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_name   = data.terraform_remote_state.vpc.outputs.vpc_name
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  # LB Info
  lb_http_listener_arn        = data.terraform_remote_state.int_lb.outputs.aws_lb_listener_http_arn
  lb_security_group_id        = data.terraform_remote_state.int_lb.outputs.aws_security_group_id
  listener_rule_path_patterns = ["/server/*"]
  listener_rule_priority      = 100
  lb_variables                = var.lb_variables

  # Shared Cluster Info
  ecs_cluster_id             = data.terraform_remote_state.cluster.outputs.aws_ecs_cluster_id
  ecs_cluster_name           = data.terraform_remote_state.cluster.outputs.aws_ecs_cluster_name
  ecs_capacity_provider_name = data.terraform_remote_state.cluster.outputs.aws_ecs_capacity_provider_name
  enable_execute_command     = true

  # IAM & ECR
  ecs_task_role_arn           = data.terraform_remote_state.iam.outputs.aws_iam_role_ecs_task_arn
  ecs_task_execution_role_arn = data.terraform_remote_state.iam.outputs.aws_iam_role_ecs_task_execution_arn
  container_definitions_json  = local.container_definitions_json

  # Autoscaling
  deployment_controller_type         = "ECS"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  # Auto Scaling
  container_desired_capacity = 1
  container_min_capacity     = 1
  container_max_capacity     = 2

  target_value       = 90  # Target 90% average CPU utilization
  scale_in_cooldown  = 180 # 3 minutes before scaling in
  scale_out_cooldown = 60  # 1 minute before scaling out again

  # Task Sizing
  task_cpu    = "400" # 0.390625 vCPU
  task_memory = "400" # 400 MiB

  log_group_name        = local.log_group_name
  log_retention_in_days = 7
}
