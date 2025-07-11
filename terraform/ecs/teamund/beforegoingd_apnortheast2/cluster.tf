module "cluster" {
  source = "../../_module/cluster"

  # Environment-specific identifiers
  shard_id = data.terraform_remote_state.vpc.outputs.shard_id

  # Networking and VPC info from remote state
  aws_region         = data.terraform_remote_state.vpc.outputs.aws_region
  vpc_name           = data.terraform_remote_state.vpc.outputs.vpc_name
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnet_ids  = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  # Security and Access
  private_ec2_key_name      = data.terraform_remote_state.vpc.outputs.aws_key_pair_private_ec2_key_name
  iam_instance_profile_name = data.terraform_remote_state.iam.outputs.aws_iam_instance_profile_ec2_name
  bastion_aware_sg          = data.terraform_remote_state.vpc.outputs.aws_security_group_bastion_aware_id

  # EC2 Instance configuration for the cluster
  instance_type        = "t2.micro"
  ec2_min_size         = 1
  ec2_max_size         = 2
  ec2_desired_capacity = 1
  swap_file_size_gb    = 2
  swappiness_value     = 70

  # Pass centralized tag variables
  sg_variables = var.sg_variables
}
