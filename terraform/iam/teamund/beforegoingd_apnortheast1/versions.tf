terraform {
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1.0"
    }

  }
}
