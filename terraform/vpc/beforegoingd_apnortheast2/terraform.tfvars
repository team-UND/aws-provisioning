aws_region = "ap-northeast-2"

# d after name indicates development
# This means that beforegoingd_apnortheast2 VPC is for development environment VPC in Seoul region
vpc_name = "beforegoingd_apnortheast2"

cidr_numeral = "10"

# Availability Zone list
availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]

internal_domain_name = "beforegoing.internal"

# shard_id will be used later when creating other resources
# With shard_id, you could distinguish which environment the resource belongs to 
shard_id       = "beforegoingdapne2"
shard_short_id = "beforegoing01d"

# Billing tag in this VPC
billing_tag = "dev"

# d means development
env_suffix = "d"

# Set to false to save costs in non-essential environments
create_interface_endpoints = false

# Enable highly available NAT gateway
enable_ha_nat_gateway = true
