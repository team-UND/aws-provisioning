terraform {
  required_version = ">= 1.10.5"

  backend "s3" {
    bucket         = "teamund-apnortheast2-tfstate"
    key            = "aws-provisioning/terraform/elasticache/teamund/beforegoingd_apnortheast2/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
