# Use module for service
module "prometheus" {
  source = "../_module/prometheus"

  # Name of service
  service_name = "prometheus"

  # Port for service and healthcheck
  service_port     = 9090
  healthcheck_port = 9090
  healthcheck_path = "/"

  # VPC Information via remote_state
  shard_id           = data.terraform_remote_state.vpc.outputs.shard_id
  public_subnet_ids  = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  aws_region         = data.terraform_remote_state.vpc.outputs.aws_region
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_name           = data.terraform_remote_state.vpc.outputs.vpc_name
  billing_tag        = data.terraform_remote_state.vpc.outputs.billing_tag

  # Domain Name
  # This will be the prefix of record
  # ex) prometheus-dev.beforegoing.com
  domain_name = "prometheus-dev"

  # Route53 variables
  acm_external_ssl_certificate_arn = var.r53_variables.preprod.star_beforegoing_site_acm_arn_apnortheast2
  route53_external_zone_id         = var.r53_variables.preprod.beforegoing_site_zone_id

  # Resource LoadBalancer variables
  lb_variables = var.lb_variables

  # Security Group variables
  sg_variables = var.sg_variables

  # Home Security Group via remote_state
  home_sg = data.terraform_remote_state.vpc.outputs.aws_security_group_home_id

  # CIDR for external LB
  # Control allowed IP for external LB
  ext_lb_ingress_cidrs = "127.0.0.1/32"

  private_ec2_key_name = data.terraform_remote_state.vpc.outputs.aws_key_pair_private_ec2_key_name

  iam_instance_profile_name = data.terraform_remote_state.iam.outputs.aws_iam_instance_profile_ec2_name
  user_data_path            = "${path.module}/user-data.sh"

  # Bastion aware Security Group via remote_state
  bastion_aware_sg = data.terraform_remote_state.vpc.outputs.aws_security_group_bastion_aware_id
}
