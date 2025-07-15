# Remote State that will be used when creating other resources
# You can add any resource here, if you want to refer from others
variable "remote_state" {
  description = "Remote state configuration for various resources"

  type = object({

    vpc = object({

      beforegoingdapne1 = object({
        region = string
        bucket = string
        key    = string
      })

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

        beforegoingdapne1 = object({
          region = string
          bucket = string
          key    = string
        })

        beforegoingdapne2 = object({
          region = string
          bucket = string
          key    = string
        })

      })

    })

    iam = object({
      teamund = object({

        beforegoingdapne1 = object({
          region = string
          bucket = string
          key    = string
        })

        beforegoingdapne2 = object({
          region = string
          bucket = string
          key    = string
        })

      })
    })

    networking = object({

      ext_lb = object({

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

    rds = object({

      mysql = object({

        beforegoingdapne1 = object({
          region = string
          bucket = string
          key    = string
        })

        beforegoingdapne2 = object({
          region = string
          bucket = string
          key    = string
        })

      })

    })

    elasticache = object({

      redis = object({

        beforegoingdapne1 = object({
          region = string
          bucket = string
          key    = string
        })

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

      beforegoingdapne1 = {
        region = "ap-northeast-1"
        bucket = "teamund-apnortheast1-tfstate"
        key    = "aws-provisioning/terraform/vpc/beforegoingd_apnortheast1/terraform.tfstate"
      }

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

        beforegoingdapne1 = {
          region = "ap-northeast-1"
          bucket = "teamund-apnortheast1-tfstate"
          key    = "aws-provisioning/terraform/ecr/teamund/beforegoingd_apnortheast1/terraform.tfstate"
        }

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

        beforegoingdapne1 = {
          region = "ap-northeast-1"
          bucket = "teamund-apnortheast1-tfstate"
          key    = "aws-provisioning/terraform/iam/teamund/beforegoingd_apnortheast1/terraform.tfstate"
        }

        beforegoingdapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/iam/teamund/beforegoingd_apnortheast2/terraform.tfstate"
        }

      }
    }

    # Networking
    networking = {

      ext_lb = {

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

    # RDS
    rds = {

      mysql = {

        beforegoingdapne1 = {
          region = "ap-northeast-1"
          bucket = "teamund-apnortheast1-tfstate"
          key    = "aws-provisioning/terraform/rds/teamund/beforegoingd_apnortheast1/terraform.tfstate"
        }

        beforegoingdapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/rds/teamund/beforegoingd_apnortheast2/terraform.tfstate"
        }

      }

    }

    # ElastiCache
    elasticache = {

      redis = {

        beforegoingdapne1 = {
          region = "ap-northeast-1"
          bucket = "teamund-apnortheast1-tfstate"
          key    = "aws-provisioning/terraform/elasticache/teamund/beforegoingd_apnortheast1/terraform.tfstate"
        }

        beforegoingdapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/elasticache/teamund/beforegoingd_apnortheast2/terraform.tfstate"
        }

      }
    }

  }
}
