aws_region = "ap-northeast-1"

# d after name indicates development
# This means that beforegoingd_apnortheast1 VPC is for development environment VPC in Tokyo region
vpc_name = "beforegoingd_apnortheast1"

cidr_numeral = "10"

# Availability Zone list
availability_zones = ["ap-northeast-1a", "ap-northeast-1c"]

internal_domain_name = "beforegoing.internal"

# shard_id will be used later when creating other resources
# With shard_id, you could distinguish which environment the resource belongs to 
shard_id = "beforegoingdapne1"

# Billing tag in this VPC
billing_tag = "dev"

# d means development
env_suffix = "d"

# Set to false to save costs in non-essential environments
create_interface_endpoints = false

# Enable highly available NAT gateway
enable_ha_nat_gateway = false
