variable "aws_region" {
  description = "The AWS region to deploy the shard storage layer into"
  type        = string
}

variable "vpc_name" {
  description = "The unique VPC name this storage layer belongs to"
  type        = string
}

variable "vpc_id" {
  description = "The AWS ID of the VPC this shard is being deployed into"
  type        = string
}

variable "shard_id" {
  description = "Text used to identify shard of infrastructure components"
  type        = string
}

variable "ec2_egress_cidr" {
  description = "CIDR block for egress traffic from ECS tasks"
  type        = string
}

variable "public_subnet_ids" {
  description = "A comma-delimited list of public subnets for the VPC"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "A comma-delimited list of private subnets for the VPC"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 Instance type"
  type        = string
  default     = "t2.micro"
}

variable "iam_instance_profile_name" {
  description = "Name of IAM instance profile"
  type        = string
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

variable "swap_file_size_gb" {
  description = "The size of the swap file in Gigabytes to create on each EC2 instance"
  type        = number
  default     = 2
}

variable "swappiness_value" {
  description = "The swappiness kernel parameter value (0-100). Lower values reduce swap usage"
  type        = number
  default     = 10
}

variable "default_capacity_provider_strategy" {
  description = "The name of the default capacity provider to use for the cluster."
  type        = string
}

variable "default_capacity_provider_base" {
  description = "The base number of tasks for the default capacity provider."
  type        = number
}

variable "default_capacity_provider_weight" {
  description = "The weight for the default capacity provider."
  type        = number
}
