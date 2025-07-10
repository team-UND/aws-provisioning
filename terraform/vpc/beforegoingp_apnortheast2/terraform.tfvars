aws_region = "ap-northeast-2"

# p after name indicates production
# This means that beforegoingp_apnortheast2 VPC is for production environment VPC in Seoul region
vpc_name = "beforegoingp_apnortheast2"

cidr_numeral = "10"

# Availability Zone list
availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]

internal_domain_name = "beforegoing.internal"

# shard_id will be used later when creating other resources
# With shard_id, you could distinguish which environment the resource belongs to 
shard_id       = "beforegoingpapne2"
shard_short_id = "beforegoing01p"

# Billing tag in this VPC
billing_tag = "prod"

# p means production
env_suffix = "p"

# Change here to your office or house
home_ips = {
  Chori-home    = "221.149.143.136/32",
  Chori-school  = "210.106.232.184/32",
  Chori-library = "118.221.199.11/32"
}

bastion_ec2_key_name = "bastion_ec2_key_pair.pem"
private_ec2_key_name = "private_ec2_key_pair.pem"
