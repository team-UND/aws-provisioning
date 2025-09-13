terraform {
  backend "s3" {
    bucket       = "teamund-global-tfstate"
    key          = "aws-provisioning/terraform/route53/teamund/beforegoing.store/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
