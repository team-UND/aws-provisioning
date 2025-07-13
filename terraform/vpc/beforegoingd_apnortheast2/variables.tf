variable "aws_region" {
  description = "AWS region to use"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "cidr_numeral" {
  description = "The VPC CIDR numeral (10.x.0.0/16)"
  type        = string
}

variable "availability_zones" {
  description = "A comma-delimited list of availability zones for the VPC"
  type        = list(string)
}

variable "cidr_numeral_public" {
  description = "The public subnet CIDR numeral (10.x.x.0/20)"
  type        = map(string)
  default = {
    0 = "0"
    1 = "16"
  }
}

variable "cidr_numeral_private" {
  description = "The private subnet CIDR numeral (10.x.x.0/20)"
  type        = map(string)
  default = {
    0 = "80"
    1 = "96"
  }
}

variable "cidr_numeral_private_db" {
  description = "The DB private subnet CIDR numeral (10.x.x.0/20)"
  type        = map(string)
  default = {
    0 = "160"
    1 = "176"
  }
}

variable "internal_domain_name" {
  description = "Base domain name for internal"
  type        = string
}

variable "shard_id" {
  description = "Shard ID for the VPC"
  type        = string
}

variable "shard_short_id" {
  description = "Short shard ID for the VPC"
  type        = string
}

variable "billing_tag" {
  description = "The AWS tag used to track AWS charges"
  type        = string
}

variable "env_suffix" {
  description = "env suffix"
  type        = string
}

variable "create_interface_endpoints" {
  description = "Controls whether to create the interface VPC endpoints"
  type        = bool
  default     = false
}

variable "enable_ha_nat_gateway" {
  description = "Controls whether to create a highly available NAT gateway"
  type        = bool
}
