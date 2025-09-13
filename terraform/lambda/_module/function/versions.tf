terraform {
  required_version = ">= 1.13.2"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.13.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7.1"
    }

  }
}
