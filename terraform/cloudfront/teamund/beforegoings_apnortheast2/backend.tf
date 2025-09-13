terraform {
  backend "s3" {
    bucket       = "teamund-apnortheast2-tfstate"
    key          = "aws-provisioning/terraform/cloudfront/teamund/beforegoings_apnortheast2/terraform.tfstate"
    region       = "ap-northeast-2"
    encrypt      = true
    use_lockfile = true
  }
}
