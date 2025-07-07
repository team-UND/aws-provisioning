variable "shard_id" {
  description = "Text used to identify shard of infrastructure components"
}

variable "aws_region" {
  description = "The AWS region to deploy the shard storage layer into"
}

variable "vpc_name" {
  description = "The unique VPC name this storage layer belongs to"
}

variable "vpc_id" {
  description = "The AWS ID of the VPC this shard is being deployed into"
}

variable "availability_zone" {
  description = "A comma-delimited list of availability zones for the VPC"
  default     = "ap-northeast-2a"
}

variable "public_subnet_ids" {
  description = "A comma-delimited list of public subnets for the VPC"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "A comma-delimited list of private subnets for the VPC"
  type        = list(string)
}

variable "ext_lb_ingress_cidrs" {
  description = "Ingress of security group of external load balancer"
}

variable "acm_external_ssl_certificate_arn" {
  description = "ssl cert id"
}

variable "instance_type" {
  description = "EC2 Instance type"
  type        = string
  default     = "t2.micro"
}

variable "private_ec2_key_name" {
  description = "Private EC2 key-pair"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "Name of IAM instance profile"
}

variable "ec2_min_size" {
  description = "Auto Scaling min size"
  type        = number
  default     = 1
}

variable "ec2_max_size" {
  description = "Auto Scaling max size"
  type        = number
  default     = 2
}

variable "ec2_desired_capacity" {
  description = "Auto Scaling desired capacity"
  type        = number
  default     = 1
}

variable "bastion_aware_sg" {
  description = "Allows ssh access from the bastion server"
}

variable "home_sg" {
  description = "Office people IP list"
}
