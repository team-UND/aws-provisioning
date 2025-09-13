terraform {
  backend "s3" {
    bucket         = "teamund-global-tfstate"
    key            = "aws-provisioning/terraform/route53/teamund/beforegoing.shop/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "global-terraform-lock"
  }
}
