# Remote State that will be used when creating other resources
# You can add any resource here, if you want to refer from others
variable "remote_state" {
  type = object({

    vpc = object({

      beforegoingdapne2 = object({
        region = string
        bucket = string
        key    = string
      })

    })

    route53 = object({

      hosting_zone = object({

        beforegoingdapne2 = object({
          region = string
          bucket = string
          key    = string
        })

      })

    })

    ecr = object({

      repository = object({

        beforegoingdapne2 = object({
          region = string
          bucket = string
          key    = string
        })

      })

    })

    iam = object({
      teamund = object({

        beforegoingdapne2 = object({
          region = string
          bucket = string
          key    = string
        })

      })
    })

    networking = object({

      external_lb = object({

        beforegoingdapne2 = object({
          region = string
          bucket = string
          key    = string
        })

      })

    })

    ecs = object({

      cluster = object({

        beforegoingdapne2 = object({
          region = string
          bucket = string
          key    = string
        })

      })

    })

    services = object({

      server = object({

        beforegoingdapne2 = object({
          region = string
          bucket = string
          key    = string
        })

      })

    })

    lambda = object({

      function = object({

        beforegoingdapne2 = object({
          region = string
          bucket = string
          key    = string
        })

      })

    })

  })

  default = {

    # VPC
    vpc = {

      beforegoingdapne2 = {
        region = "ap-northeast-2"
        bucket = "teamund-apnortheast2-tfstate"
        key    = "aws-provisioning/terraform/vpc/beforegoingd_apnortheast2/terraform.tfstate"
      }

    }

    # Route53
    route53 = {

      hosting_zone = {

        beforegoingdapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/route53/teamund/beforegoing.site/terraform.tfstate"
        }

      }

    }

    # ECR
    ecr = {

      repository = {

        beforegoingdapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/ecr/teamund/beforegoingd_apnortheast2/terraform.tfstate"
        }

      }

    }

    # IAM
    iam = {
      teamund = {

        beforegoingdapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/iam/teamund/beforegoingd_apnortheast2/terraform.tfstate"
        }

      }
    }

    # Networking
    networking = {

      external_lb = {

        beforegoingdapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/networking/teamund/beforegoingd_apnortheast2/terraform.tfstate"
        }

      }

    }

    # ECS
    ecs = {

      cluster = {

        beforegoingdapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/ecs/teamund/beforegoingd_apnortheast2/terraform.tfstate"
        }

      }

    }

    # Services
    services = {

      server = {

        beforegoingdapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/services/teamund/beforegoingd_apnortheast2/terraform.tfstate"
        }

      }
    }

    # Lambda
    lambda = {

      function = {

        beforegoingdapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/lambda/teamund/beforegoingd_apnortheast2/terraform.tfstate"
        }

      }
    }

  }
}
