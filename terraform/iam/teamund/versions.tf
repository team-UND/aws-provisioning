terraform {
  required_version = ">= 1.13.2"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.13.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1.0"
    }

  }
}
