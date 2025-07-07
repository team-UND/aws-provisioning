# Use module for service
module "server" {
  source = "../_module/server"

  # Name of service
  service_name = "server"

  # Domain Name
  # This will be the prefix of record
  # ex) server-dev.beforegoing.com
  domain_name = "server-dev.beforegoing.site"

  # Port for service and healthcheck
  service_port      = 8080
  health_check_port = 10090
  health_check_path = "/actuator/health"

  # VPC Information via remote_state
  shard_id           = data.terraform_remote_state.vpc.outputs.shard_id
  aws_region         = data.terraform_remote_state.vpc.outputs.aws_region
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_name           = data.terraform_remote_state.vpc.outputs.vpc_name
  public_subnet_ids  = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  # Shared Cluster Info
  ecs_cluster_id   = data.terraform_remote_state.cluster.outputs.aws_ecs_cluster_default_id
  ecs_cluster_name = data.terraform_remote_state.cluster.outputs.aws_ecs_cluster_default_name

  # Shared ALB Info
  alb_https_listener_arn = data.terraform_remote_state.cluster.outputs.aws_lb_listener_external_https_arn
  alb_security_group_id  = data.terraform_remote_state.cluster.outputs.aws_security_group_external_lb_id
  alb_dns_name           = data.terraform_remote_state.cluster.outputs.aws_lb_external_dns_name
  alb_zone_id            = data.terraform_remote_state.cluster.outputs.aws_lb_external_zone_id

  # Route53 variables
  route53_external_zone_id = var.r53_variables.preprod.beforegoing_site_zone_id
  listener_rule_priority   = 100

  # Resource LoadBalancer variables
  lb_variables = var.lb_variables

  # IAM & ECR
  ecs_task_execution_role_arn = data.terraform_remote_state.iam.outputs.aws_iam_role_ecs_task_execution_arn
  container_image_url         = "${data.terraform_remote_state.ecr.outputs.aws_ecr_repository_server_build_repository_url}:latest"
  prometheus_image_url        = "${data.terraform_remote_state.ecr.outputs.aws_ecr_repository_prometheus_build_repository_url}:latest"

  # Task Sizing
  task_cpu    = "256"
  task_memory = "512"

  # Auto Scaling
  container_desired_capacity = 1
  container_min_capacity     = 1
  container_max_capacity     = 2

  cloudwatch_log_retention_in_days = 3
}
