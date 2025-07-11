module "lb" {
  source = "../../_module/external_lb"

  # Environment-specific identifiers
  shard_id = data.terraform_remote_state.vpc.outputs.shard_id

  # Networking and VPC info from remote state
  vpc_name          = data.terraform_remote_state.vpc.outputs.vpc_name
  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  lb_ingress_cidrs  = "0.0.0.0/0" # Allow traffic from anywhere to the ALB
  lb_egress_cidrs   = "0.0.0.0/0" # Allow traffic to anywhere from the ALB
  lb_type           = "application"
  public_subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnet_ids

  # Security and Access
  acm_external_ssl_certificate_arn = var.r53_variables.dev.star_beforegoing_site_acm_arn_apnortheast2

  # Pass centralized tag variables
  lb_variables = var.lb_variables
  sg_variables = var.sg_variables
}
