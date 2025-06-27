# Remote State that will be used when creating other resources
# You can add any resource here, if you want to refer from others
variable "remote_state" {
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
      teamund = {

        beforegoingdapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/route53/teamund/beforegoing.site/terraform.tfstate"
        }

      }
    }

    # Services
    services = {
      server = {

        beforegoingdapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/services/server/beforegoingd_apnortheast2/terraform.tfstate"
        }

      }
    }

    # RDS
    rds = {
      teamund = {

        beforegoingdapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioing/terraform/rds/teamund/beforegoingd_apnortheast2/terraform.tfstate"
        }

      }
    }

    # ECR
    ecr = {
      teamund = {

        beforegoingdapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/ecr/teamund/beforegoingd_apnortheast2/terraform.tfstate"
        }

      }
    }

    # S3
    s3 = {
      teamund = {

        beforegoingdapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/s3/teamund/beforegoingd_apnortheast2/terraform.tfstate"
        }

      }
    }

    # CodeDeploy
    codedeploy = {
      teamund = {

        beforegoingdapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/codedeploy/teamund/beforegoingd_apnortheast2/terraform.tfstate"
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

    # Lambda
    lambda = {
      teamund = {

        beforegoingdapne2 = {
          region = "ap-northeast-2"
          bucket = "teamund-apnortheast2-tfstate"
          key    = "aws-provisioning/terraform/lambda/teamund/beforegoingd_apnortheast2/terraform.tfstate"
        }

      }
    }

  }
}
