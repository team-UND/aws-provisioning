terraform {
  backend "s3" {
    bucket         = "teamund-apnortheast2-tfstate"
    key            = "aws-provisioning/terraform/resource_explorer/teamund/apnortheast2/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
