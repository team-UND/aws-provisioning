terraform {
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7.1"
    }

  }
}

provider "aws" {
  region = data.terraform_remote_state.vpc.outputs.aws_region
}

provider "archive" {}
