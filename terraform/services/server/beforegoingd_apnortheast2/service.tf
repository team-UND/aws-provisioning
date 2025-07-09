locals {
  service_name      = "server"
  service_port      = 8080
  health_check_port = 10090

  # Define any variables needed by the container definition template here
  template_vars = {
    service_name               = local.service_name
    app_image_url              = "${data.terraform_remote_state.ecr.outputs.aws_ecr_repository_beforegoingd_server_build_repository_url}:latest"
    observability_sidecar_name = "prometheus"
    observability_image_url    = "${data.terraform_remote_state.ecr.outputs.aws_ecr_repository_beforegoingd_prometheus_build_repository_url}:latest"
    service_port               = local.service_port
    max_swap                   = 1024
    swappiness                 = 60
    spring_profiles_active     = data.terraform_remote_state.vpc.outputs.billing_tag
    app_log_group_name         = aws_cloudwatch_log_group.app.name
    sidecar_log_group_name     = aws_cloudwatch_log_group.observability_sidecar.name
    aws_region                 = data.terraform_remote_state.vpc.outputs.aws_region
    rdb_secrets_arn            = "arn:aws:secretsmanager:ap-northeast-2:116541189059:secret:rds!db-80ac3114-1cd0-4105-8b7c-9f24c1b78e56-2swVBu"
    app_secrets_arn            = "arn:aws:secretsmanager:ap-northeast-2:116541189059:secret:SpringBoot-Secrets-shvyH2"
  }

  # Render the container definition template using the variables defined above
  container_definitions_json = templatefile("${path.module}/container-definitions.json.tftpl", local.template_vars)
}

# Use module for service
module "server" {
  source = "../_module/server"

  # Name of service
  service_name = local.service_name

  # Domain Name
  domain_name = "${local.service_name}-${data.terraform_remote_state.vpc.outputs.billing_tag}.${data.terraform_remote_state.route53.outputs.aws_route53_zone_beforegoing_site_name}"

  # Port for service and healthcheck
  service_port      = local.service_port
  health_check_port = local.health_check_port
  health_check_path = "/actuator/health"

  # VPC Information via remote_state
  shard_id           = data.terraform_remote_state.vpc.outputs.shard_id
  aws_region         = data.terraform_remote_state.vpc.outputs.aws_region
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_name           = data.terraform_remote_state.vpc.outputs.vpc_name
  public_subnet_ids  = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  # Shared Cluster Info
  ecs_cluster_id             = data.terraform_remote_state.cluster.outputs.aws_ecs_cluster_default_id
  ecs_cluster_name           = data.terraform_remote_state.cluster.outputs.aws_ecs_cluster_default_name
  ecs_capacity_provider_name = data.terraform_remote_state.cluster.outputs.aws_ecs_capacity_provider_default_name

  # Shared ALB Info
  alb_https_listener_arn = data.terraform_remote_state.cluster.outputs.aws_lb_listener_external_https_arn
  alb_security_group_id  = data.terraform_remote_state.cluster.outputs.aws_security_group_external_lb_id
  alb_dns_name           = data.terraform_remote_state.cluster.outputs.aws_lb_external_dns_name
  alb_zone_id            = data.terraform_remote_state.cluster.outputs.aws_lb_external_zone_id

  # Route53 variables
  route53_external_zone_id = var.r53_variables.dev.beforegoing_site_zone_id
  listener_rule_priority   = 100

  # Resource LoadBalancer variables
  lb_variables = var.lb_variables

  # IAM & ECR
  ecs_task_execution_role_arn = data.terraform_remote_state.iam.outputs.aws_iam_role_ecs_task_execution_arn
  container_definitions_json  = local.container_definitions_json

  # Task Sizing
  task_cpu               = "512" # 0.50 vCPU
  task_memory_hard_limit = "512" # 512 MiB

  health_check_grace_period_seconds = 90

  # Auto Scaling
  container_desired_capacity = 1
  container_min_capacity     = 1
  container_max_capacity     = 2
}

# Create the necessary log groups for the containers in this specific environment
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${local.service_name}-app"
  retention_in_days = 3
}

resource "aws_cloudwatch_log_group" "observability_sidecar" {
  name              = "/ecs/${local.service_name}-observability"
  retention_in_days = 3
}
