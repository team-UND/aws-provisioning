terraform {
  backend "s3" {
    region         = "ap-northeast-1"
    bucket         = "teamund-apnortheast1-tfstate"
    key            = "aws-provisioning/terraform/route53/teamund/beforegoing.store/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
