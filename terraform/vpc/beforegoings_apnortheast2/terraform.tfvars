aws_region = "ap-northeast-2"

# s after name indicates staging
# This means that beforegoings_apnortheast2 VPC is for staging environment VPC in Seoul region
vpc_name = "beforegoings_apnortheast2"

cidr_numeral = "10"

# Availability Zone list
availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]

internal_domain_name = "beforegoings.internal"

# shard_id will be used later when creating other resources
# With shard_id, you could distinguish which environment the resource belongs to 
shard_id = "beforegoingsapne2"

# Billing tag in this VPC
billing_tag = "stg"

# s means staging
env_suffix = "p"

home_ips = {
  "Chori-home" = "221.149.143.136/32"
}

# Set to false to save costs in non-essential environments
create_interface_endpoints = false

# Enable highly available NAT gateway
enable_ha_nat_gateway = false
