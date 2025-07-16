terraform {
  backend "s3" {
    bucket         = "teamund-apnortheast2-tfstate"
    key            = "aws-provisioning/terraform/ecr/teamund/beforegoingp_apnortheast2/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
