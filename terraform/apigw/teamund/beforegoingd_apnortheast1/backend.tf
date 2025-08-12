terraform {
  backend "s3" {
    bucket         = "teamund-apnortheast1-tfstate"
    key            = "aws-provisioning/terraform/apigw/teamund/beforegoingd_apnortheast1/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
