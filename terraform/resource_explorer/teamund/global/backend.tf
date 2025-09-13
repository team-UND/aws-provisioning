terraform {
  backend "s3" {
    bucket       = "teamund-global-tfstate"
    key          = "aws-provisioning/terraform/resource_explorer/teamund/global/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
