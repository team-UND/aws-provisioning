data "aws_secretsmanager_secret" "app_secrets" {
  name = "dev/server/springboot"
}

data "aws_secretsmanager_secret" "prometheus_secrets" {
  name = "dev/prometheus"
}

resource "aws_vpc_security_group_ingress_rule" "ar_mysql" {
  description                  = "Allow traffic from the App Runner to the MySQL"
  security_group_id            = data.terraform_remote_state.mysql.outputs.aws_security_group_id
  from_port                    = data.terraform_remote_state.mysql.outputs.port
  to_port                      = data.terraform_remote_state.mysql.outputs.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = module.service.aws_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "ar_redis" {
  description                  = "Allow traffic from the App Runner to the Redis"
  security_group_id            = data.terraform_remote_state.redis.outputs.aws_security_group_id
  from_port                    = data.terraform_remote_state.redis.outputs.port
  to_port                      = data.terraform_remote_state.redis.outputs.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = module.service.aws_security_group_id
}

module "service" {
  source = "../../_module/service"

  service_name = "server"

  access_role_arn = data.terraform_remote_state.iam.outputs.aws_iam_role_ar_service_arn

  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_name = data.terraform_remote_state.vpc.outputs.vpc_name
  shard_id = data.terraform_remote_state.vpc.outputs.shard_id

  image_url             = data.terraform_remote_state.repository.outputs.aws_ecr_repository_server_build_repository_url
  image_tag             = "6cb05a8"
  image_repository_type = "ECR"

  domain_name          = data.terraform_remote_state.hosting_zone.outputs.aws_route53_zone_name
  subdomain_name       = var.subdomain_name
  enable_www_subdomain = false

  container_port = 8080

  environment_variables = {
    SPRING_PROFILES_ACTIVE     = data.terraform_remote_state.vpc.outputs.billing_tag
    SPRING_DATASOURCE_HOSTNAME = data.terraform_remote_state.mysql.outputs.aws_db_instance_address
  }

  environment_secrets = {
    SPRING_DATASOURCE_PORT          = "${data.aws_secretsmanager_secret.app_secrets.arn}:SPRING_DATASOURCE_PORT::"
    SPRING_DATASOURCE_DATABASE_NAME = "${data.aws_secretsmanager_secret.app_secrets.arn}:SPRING_DATASOURCE_DATABASE_NAME::"
    SPRING_DATASOURCE_USERNAME      = "${data.terraform_remote_state.mysql.outputs.aws_db_master_user_secret_arn}:username::"
    SPRING_DATASOURCE_PASSWORD      = "${data.terraform_remote_state.mysql.outputs.aws_db_master_user_secret_arn}:password::"
    SPRING_REDIS_HOST               = "${data.aws_secretsmanager_secret.app_secrets.arn}:SPRING_REDIS_HOST::"
    SPRING_REDIS_PORT               = "${data.aws_secretsmanager_secret.app_secrets.arn}:SPRING_REDIS_PORT::"
    OAUTH_KAKAO_APP_KEY             = "${data.aws_secretsmanager_secret.app_secrets.arn}:OAUTH_KAKAO_APP_KEY::"
    OAUTH_APPLE_APP_ID              = "${data.aws_secretsmanager_secret.app_secrets.arn}:OAUTH_APPLE_APP_ID::"
    ISSUER_NAME                     = "${data.aws_secretsmanager_secret.app_secrets.arn}:ISSUER_NAME::"
    JWT_SECRET                      = "${data.aws_secretsmanager_secret.app_secrets.arn}:JWT_SECRET::"
    ACCESS_TOKEN_EXPIRE_TIME        = "${data.aws_secretsmanager_secret.app_secrets.arn}:ACCESS_TOKEN_EXPIRE_TIME::"
    REFRESH_TOKEN_EXPIRE_TIME       = "${data.aws_secretsmanager_secret.app_secrets.arn}:REFRESH_TOKEN_EXPIRE_TIME::"
    SENTRY_DSN                      = "${data.aws_secretsmanager_secret.app_secrets.arn}:SENTRY_DSN::"
    KMA_SERVICE_KEY                 = "${data.aws_secretsmanager_secret.app_secrets.arn}:KMA_SERVICE_KEY::"
    PROMETHEUS_USERNAME             = "${data.aws_secretsmanager_secret.prometheus_secrets.arn}:USERNAME::"
    PROMETHEUS_PASSWORD             = "${data.aws_secretsmanager_secret.prometheus_secrets.arn}:PASSWORD::"
  }

  auto_deploy = false

  instance_role_arn = data.terraform_remote_state.iam.outputs.aws_iam_role_ar_instance_arn
  cpu               = 512
  memory            = 1024

  autoscaling_min_size        = 1
  autoscaling_max_size        = 2
  autoscaling_max_concurrency = 200

  is_publicly_accessible = true
  subnet_ids             = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  ar_egress_cidr         = "0.0.0.0/0"

  lb_variables = var.lb_variables

  web_acl_arn          = data.terraform_remote_state.acl.outputs.regional_aws_wafv2_web_acl_arn
  enable_observability = true
}
