module "external" {
  source = "../../_module/external"

  aws_region = data.terraform_remote_state.vpc.outputs.aws_region

  # Networking and VPC info from remote state
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_name = data.terraform_remote_state.vpc.outputs.vpc_name

  # Environment-specific identifiers
  shard_id = data.terraform_remote_state.vpc.outputs.shard_id

  # Allow traffic from the ALB to within the VPC
  lb_ingress_cidrs  = data.terraform_remote_state.vpc.outputs.home_ips
  lb_egress_cidr    = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  lb_type           = "application"
  public_subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnet_ids

  # Route53
  route53_zone_id = data.terraform_remote_state.hosting_zone.outputs.aws_route53_zone_id
  domain_name     = data.terraform_remote_state.hosting_zone.outputs.aws_route53_zone_name
  subdomain_name  = "observability"

  # Pass centralized tag variables
  lb_variables = var.lb_variables
  sg_variables = var.sg_variables
}
