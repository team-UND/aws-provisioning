module "internal" {
  source = "../../_module/internal"

  # Networking and VPC info from remote state
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_name = data.terraform_remote_state.vpc.outputs.vpc_name

  # Environment-specific identifiers
  shard_id = data.terraform_remote_state.vpc.outputs.shard_id

  # Allow traffic from the ALB to within the VPC
  lb_egress_cidr     = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  lb_type            = "application"
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  # Pass centralized tag variables
  lb_variables = var.lb_variables
  sg_variables = var.sg_variables
}
