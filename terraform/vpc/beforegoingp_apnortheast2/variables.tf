variable "aws_region" {
  default = "ap-northeast-2"
}

variable "vpc_name" {
  description = "The name of the VPC"
}

variable "cidr_numeral" {
  description = "The VPC CIDR numeral (10.x.0.0/16)"
}

variable "availability_zones" {
  description = "A comma-delimited list of availability zones for the VPC"
  type        = list(string)
}

variable "availability_zones_without_b" {
  description = "A comma-delimited list of availability zones except for ap-northeast-2b"
  type        = list(string)
}

variable "cidr_numeral_public" {
  default = {
    0 = "0"
    1 = "16"
  }
}

variable "cidr_numeral_private" {
  default = {
    0 = "80"
    1 = "96"
  }
}

variable "cidr_numeral_private_db" {
  default = {
    0 = "160"
    1 = "176"
  }
}

variable "internal_domain_name" {
  description = "Base domain name for internal"
}

variable "shard_id" {
  default = ""
}

variable "shard_short_id" {
  default = ""
}

variable "billing_tag" {
  description = "The AWS tag used to track AWS charges"
}

variable "env_suffix" {
  description = "env suffix"
}

variable "home_ips" {
  default = {
    Chori-home = "221.149.143.136/32"
  }
}

variable "bastion_ec2_key_name" {
  description = "Bastion EC2 key-pair"
  type        = string
}

variable "private_ec2_key_name" {
  description = "Private EC2 key-pair"
  type        = string
}
