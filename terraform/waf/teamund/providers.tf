provider "aws" {
  region = data.terraform_remote_state.vpc.outputs.aws_region
}

# Aliased provider for the us-east-1 region, specifically for CloudFront WAF resources
provider "aws" {
  alias  = "global"
  region = "us-east-1"
}
