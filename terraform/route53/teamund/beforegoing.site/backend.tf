terraform {
  required_version = ">= 1.10.5"

  backend "s3" {
    bucket         = "teamund-apnortheast2-tfstate"
    key            = "aws-provisioning/terraform/route53/teamund/beforegoing.site/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
