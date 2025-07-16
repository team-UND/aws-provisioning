aws_region = "ap-northeast-2"

# p after name indicates production
# This means that beforegoingp_apnortheast2 VPC is for production environment VPC in Seoul region
vpc_name = "beforegoingp_apnortheast2"

cidr_numeral = "10"

# Availability Zone list
availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]

internal_domain_name = "beforegoingp.internal"

# shard_id will be used later when creating other resources
# With shard_id, you could distinguish which environment the resource belongs to 
shard_id = "beforegoingpapne2"

# Billing tag in this VPC
billing_tag = "prod"

# p means production
env_suffix = "p"

# Set to false to save costs in non-essential environments
create_interface_endpoints = false

# Enable highly available NAT gateway
enable_ha_nat_gateway = true
