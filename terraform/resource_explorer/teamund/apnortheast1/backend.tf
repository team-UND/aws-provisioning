terraform {
  backend "s3" {
    bucket       = "teamund-apnortheast1-tfstate"
    key          = "aws-provisioning/terraform/resource_explorer/teamund/apnortheast1/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}
