data "aws_secretsmanager_secret" "app_secrets" {
  name = "SpringBoot-Secrets"
}

locals {
  shard_id          = data.terraform_remote_state.vpc.outputs.shard_id
  service_name      = "server"
  service_port      = 8080
  health_check_port = 10090
  log_group_name    = "/services/${local.shard_id}/${local.service_name}"

  # Define any variables needed by the container definition template here
  template_vars = {
    aws_region                  = data.terraform_remote_state.vpc.outputs.aws_region
    service_name                = local.service_name
    image_url                   = data.terraform_remote_state.repository.outputs.aws_ecr_repository_server_build_repository_url
    container_cpu_limit         = 432
    container_memory_hard_limit = 432
    container_memory_soft_limit = 432
    max_swap                    = 1024
    swappiness                  = 70
    service_port                = local.service_port
    health_check_port           = local.health_check_port
    spring_profiles_active      = data.terraform_remote_state.vpc.outputs.billing_tag
    log_group_name              = local.log_group_name
    rdb_secrets_arn             = data.terraform_remote_state.mysql.outputs.aws_db_master_user_secret_arn
    app_secrets_arn             = data.aws_secretsmanager_secret.app_secrets.arn
  }

  # Render the container definition template using the variables defined above
  container_definitions_json = templatefile("${path.module}/container-definitions.json.tftpl", local.template_vars)
}

resource "aws_vpc_security_group_ingress_rule" "mysql" {
  description                  = "Allow traffic from service to MySQL"
  security_group_id            = data.terraform_remote_state.mysql.outputs.aws_security_group_id
  from_port                    = data.terraform_remote_state.mysql.outputs.port
  to_port                      = data.terraform_remote_state.mysql.outputs.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = module.server.aws_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "redis" {
  description                  = "Allow traffic from service to Redis"
  security_group_id            = data.terraform_remote_state.redis.outputs.aws_security_group_id
  from_port                    = data.terraform_remote_state.redis.outputs.port
  to_port                      = data.terraform_remote_state.redis.outputs.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = module.server.aws_security_group_id
}

# Use module for service
module "server" {
  source = "../../_module/server"

  # Name of service
  service_name = local.service_name

  # Domain Name
  domain_name = "${local.service_name}-dev.${data.terraform_remote_state.hosting_zone.outputs.aws_route53_zone_name}"

  # Port for service and healthcheck
  service_port                      = local.service_port
  health_check_port                 = local.health_check_port
  health_check_path                 = "/actuator/health"
  health_check_grace_period_seconds = 90

  # VPC Information via remote_state
  shard_id   = local.shard_id
  aws_region = data.terraform_remote_state.vpc.outputs.aws_region
  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_name   = data.terraform_remote_state.vpc.outputs.vpc_name
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  # Shared LB Info
  lb_https_listener_arn = data.terraform_remote_state.external_lb.outputs.aws_lb_listener_https_arn
  lb_security_group_id  = data.terraform_remote_state.external_lb.outputs.aws_security_group_id
  lb_dns_name           = data.terraform_remote_state.external_lb.outputs.aws_lb_dns_name
  lb_zone_id            = data.terraform_remote_state.external_lb.outputs.aws_lb_zone_id

  # Shared Cluster Info
  ecs_cluster_id             = data.terraform_remote_state.cluster.outputs.aws_ecs_cluster_id
  ecs_cluster_name           = data.terraform_remote_state.cluster.outputs.aws_ecs_cluster_name
  ecs_capacity_provider_name = data.terraform_remote_state.cluster.outputs.aws_ecs_capacity_provider_name
  enable_execute_command     = true

  # Route53 variables
  route53_zone_id        = var.r53_variables.dev.beforegoing_site_zone_id
  listener_rule_priority = 100

  # Resource LoadBalancer variables
  lb_variables = var.lb_variables

  # IAM & ECR
  ecs_task_role_arn           = data.terraform_remote_state.iam.outputs.aws_iam_role_ecs_task_arn
  ecs_task_execution_role_arn = data.terraform_remote_state.iam.outputs.aws_iam_role_ecs_task_execution_arn
  container_definitions_json  = local.container_definitions_json

  # Auto Scaling
  container_desired_capacity = 1
  container_min_capacity     = 1
  container_max_capacity     = 2

  target_value       = 80  # Target 80% average CPU utilization
  scale_in_cooldown  = 180 # 3 minutes before scaling in
  scale_out_cooldown = 60  # 1 minute before scaling out again

  # Task Sizing
  task_cpu    = "432" # 0.421875 vCPU
  task_memory = "432" # 432 MiB

  log_group_name        = local.log_group_name
  log_retention_in_days = 7
}
