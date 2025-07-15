provider "aws" {
  region = data.terraform_remote_state.vpc.outputs.aws_region
}
