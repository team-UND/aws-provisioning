locals {
  scope = "REGIONAL"
}

# This IP Set is used for permanently blocking specific IP addresses
resource "aws_wafv2_ip_set" "permanent_block_ips" {
  name               = "permanent-block-ips-${data.terraform_remote_state.vpc.outputs.vpc_name}"
  scope              = local.scope
  ip_address_version = "IPV4"
  addresses = [

  ]

  tags = {
    Name = "permanent-block-ips-${data.terraform_remote_state.vpc.outputs.vpc_name}"
  }
}

# This IP Set is used for temporary blocking of specific IP addresses
resource "aws_wafv2_ip_set" "temporary_block_ips" {
  name               = "temporary-block-ips-${data.terraform_remote_state.vpc.outputs.vpc_name}"
  scope              = local.scope
  ip_address_version = "IPV4"
  addresses = [

  ]

  tags = {
    Name         = "temporary-block-ips-${data.terraform_remote_state.vpc.outputs.vpc_name}"
    ManagedUntil = "2025-12-31"
  }
}

module "regional" {
  source = "../../_module/acl"

  vpc_name = data.terraform_remote_state.vpc.outputs.vpc_name

  name  = "regional"
  scope = local.scope

  rate_limit = 100

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

  common_rule_set_exceptions = []
}
