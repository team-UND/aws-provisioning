module "ext_lb" {
  source = "../../_module/ext_lb"

  # Environment-specific identifiers
  shard_id = data.terraform_remote_state.vpc.outputs.shard_id

  # Networking and VPC info from remote state
  vpc_name = data.terraform_remote_state.vpc.outputs.vpc_name
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id

  # To restrict access, change this map to your specific IPs
  # For a public service, use "0.0.0.0/0"
  lb_ingress_cidrs = {
    "AllowAll" = "0.0.0.0/0"
    # Example for restricted access:
    # "Chori-home" = "221.149.143.136/32"
  }
  # Allow traffic from the ALB to within the VPC
  lb_egress_cidr    = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  lb_type           = "application"
  public_subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnet_ids

  # Security and Access
  acm_external_ssl_certificate_arn = var.r53_variables.dev.star_beforegoing_site_acm_arn_apnortheast2

  # Pass centralized tag variables
  lb_variables = var.lb_variables
  sg_variables = var.sg_variables
}
