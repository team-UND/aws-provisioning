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

      beforegoingsapne2 = object({
        region = string
        bucket = string
        key    = string
      })

      beforegoingpapne2 = object({
        region = string
        bucket = string
        key    = string
      })

    })

    route53 = object({

      hosting_zone = object({

        beforegoingdapne1 = object({
          region = string
          bucket = string
          key    = string
        })

        beforegoingpapne2 = object({
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

        beforegoingpapne2 = object({
          region = string
          bucket = string
          key    = string
        })

      })

    })

    iam = object({
      teamund = object({

        global = object({
          region = string
          bucket = string
          key    = string
        })

        beforegoingdapne1 = object({
          region = string
          bucket = string
          key    = string
        })

        beforegoingsapne2 = object({
          region = string
          bucket = string
          key    = string
        })

        beforegoingpapne2 = object({
          region = string
          bucket = string
          key    = string
        })

      })
    })

    lb = object({

      internal = object({

        beforegoingsapne2 = object({
          region = string
          bucket = string
          key    = string
        })

        beforegoingpapne2 = object({
          region = string
          bucket = string
          key    = string
        })

      })

    })

    ecs = object({

      cluster = object({

        beforegoingpapne2 = object({
          region = string
          bucket = string
          key    = string
        })

      })

    })

    s3 = object({

      bucket = object({

        beforegoingsapne2 = object({
          region = string
          bucket = string
          key    = string
        })

        beforegoingpapne2 = object({
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

        beforegoingsapne2 = object({
          region = string
          bucket = string
          key    = string
        })

        beforegoingpapne2 = object({
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

        beforegoingsapne2 = object({
          region = string
          bucket = string
          key    = string
        })

        beforegoingpapne2 = object({
          region = string
          bucket = string
          key    = string
        })

      })

    })

    ar = object({

      service = object({

        beforegoingdapne1 = object({
          region = string
          bucket = string
          key    = string
        })

      })

    })

    lambda = object({

      function = object({

        beforegoingpapne2 = object({
          region = string
          bucket = string
          key    = string
        })

      })

    })

    apigw = object({

      http = object({

        beforegoingpapne2 = object({
          region = string
          bucket = string
          key    = string
        })

      })

    })

    waf = object({

      acl = object({

        beforegoingpapne2 = object({
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

      beforegoingsapne2 = {
        region = "ap-northeast-2"
        bucket = "teamund-apnortheast2-tfstate"
        key    = "aws-provisioning/terraform/vpc/beforegoings_apnortheast2/terraform.tfstate"
      }

      beforegoingpapne2 = {
        region = "ap-northeast-2"
        bucket = "teamund-apnortheast2-tfstate"
        key    = "aws-provisioning/terraform/vpc/beforegoingp_apnortheast2/terraform.tfstate"
      }

    }

    # Route53
    route53 = {

      hosting_zone = {

        beforegoingdapne1 = {
          region = "ap-northeast-1"
          bucket = "teamund-apnortheast1-tfstate"
          key    = "aws-provisioning/terraform/route53/teamund/beforegoing.store/terraform.tfstate"
        }

        beforegoingpapne2 = {
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

        beforegoingpapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/ecr/teamund/beforegoingp_apnortheast2/terraform.tfstate"
        }

      }

    }

    # IAM
    iam = {
      teamund = {

        global = {
          region = "us-east-1"
          bucket = "teamund-global-tfstate"
          key    = "aws-provisioning/terraform/iam/teamund/global/terraform.tfstate"
        }

        beforegoingdapne1 = {
          region = "ap-northeast-1"
          bucket = "teamund-apnortheast1-tfstate"
          key    = "aws-provisioning/terraform/iam/teamund/beforegoingd_apnortheast1/terraform.tfstate"
        }

        beforegoingsapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/iam/teamund/beforegoings_apnortheast2/terraform.tfstate"
        }

        beforegoingpapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/iam/teamund/beforegoingp_apnortheast2/terraform.tfstate"
        }

      }
    }

    # LB
    lb = {

      internal = {

        beforegoingsapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/lb/teamund/beforegoings_apnortheast2/terraform.tfstate"
        }

        beforegoingpapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/lb/teamund/beforegoingp_apnortheast2/terraform.tfstate"
        }

      }

    }

    # ECS
    ecs = {

      cluster = {

        beforegoingpapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/ecs/teamund/beforegoingp_apnortheast2/terraform.tfstate"
        }

      }

    }

    # S3
    s3 = {

      bucket = {

        beforegoingsapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/s3/teamund/beforegoings_apnortheast2/terraform.tfstate"
        }

        beforegoingpapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/s3/teamund/beforegoingp_apnortheast2/terraform.tfstate"
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

        beforegoingsapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/rds/teamund/beforegoings_apnortheast2/terraform.tfstate"
        }

        beforegoingpapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/rds/teamund/beforegoingp_apnortheast2/terraform.tfstate"
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

        beforegoingsapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/elasticache/teamund/beforegoings_apnortheast2/terraform.tfstate"
        }

        beforegoingpapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/elasticache/teamund/beforegoingp_apnortheast2/terraform.tfstate"
        }

      }
    }

    # App Runner
    ar = {

      service = {

        beforegoingdapne1 = {
          region = "ap-northeast-1"
          bucket = "teamund-apnortheast1-tfstate"
          key    = "aws-provisioning/terraform/ar/teamund/beforegoingd_apnortheast1/terraform.tfstate"
        }

      }
    }

    # Lambda
    lambda = {

      function = {

        beforegoingpapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/lambda/teamund/beforegoingp_apnortheast2/terraform.tfstate"
        }

      }
    }

    # API Gateway
    apigw = {

      http = {

        beforegoingpapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/apigw/teamund/beforegoingp_apnortheast2/terraform.tfstate"
        }

      }
    }

    # WAF
    waf = {

      acl = {

        beforegoingpapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/waf/teamund/beforegoingp_apnortheast2/terraform.tfstate"
        }

      }
    }

  }
}
