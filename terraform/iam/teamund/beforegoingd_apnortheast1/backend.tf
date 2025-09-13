terraform {
  backend "s3" {
    bucket       = "teamund-apnortheast1-tfstate"
    key          = "aws-provisioning/terraform/iam/teamund/beforegoingd_apnortheast1/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}
