locals {
  vpc_name = data.terraform_remote_state.vpc.outputs.vpc_name
  shard_id = data.terraform_remote_state.vpc.outputs.shard_id
}
