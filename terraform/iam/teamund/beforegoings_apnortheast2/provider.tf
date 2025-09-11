provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "vpc_region"
  region = data.terraform_remote_state.vpc.outputs.aws_region
}

provider "tls" {}
