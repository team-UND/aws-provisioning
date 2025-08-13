locals {
  scope = "CLOUDFRONT"
}

# This IP Set is used for permanently blocking specific IP addresses
resource "aws_wafv2_ip_set" "permanent_block_ips" {
  provider = aws.global

  name               = "permanent-block-ips"
  scope              = local.scope
  ip_address_version = "IPV4"
  addresses = [

  ]

  tags = {
    Name = "permanent-block-ips"
  }
}

# This IP Set is used for temporary blocking of specific IP addresses
resource "aws_wafv2_ip_set" "temporary_block_ips" {
  provider = aws.global

  name               = "temporary-block-ips"
  scope              = local.scope
  ip_address_version = "IPV4"
  addresses = [

  ]

  tags = {
    Name         = "temporary-block-ips"
    ManagedUntil = "2025-12-31"
  }
}

module "cloudfront" {
  source = "../../_module/acl"

  providers = {
    aws = aws.global
  }

  vpc_name = data.terraform_remote_state.vpc.outputs.vpc_name

  name  = "cloudfront"
  scope = local.scope

  rate_limit = 2000

  ip_set_rules = {
    # This rule is for permanently blocking specific IP addresses
    "Permanent-Block-Ips" = {
      priority = 1
      arn      = aws_wafv2_ip_set.permanent_block_ips.arn
    },
    # This rule is for temporary blocking of IP addresses
    "Temporary-Block-Ips" = {
      priority = 2
      arn      = aws_wafv2_ip_set.temporary_block_ips.arn
    }
  }

  common_rule_set_exceptions = [
    {
    }
  ]
}
