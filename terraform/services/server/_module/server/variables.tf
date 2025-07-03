variable "service_name" {
  description = "The name of this service"
}

# For new shards, this should only be the shard ID and must not include the AWS region
# For example, use apne2, not ap-northeast-2
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

variable "billing_tag" {
  description = "The shard's default billing tag"
}

variable "route53_external_zone_id" {
  description = "r53 zone id"
}

variable "domain_name" {
  description = "Domain Name"
}

variable "acm_external_ssl_certificate_arn" {
  description = "ssl cert id"
}

variable "ext_lb_ingress_cidrs" {
  description = "Ingress of security group of external load balancer"
}

variable "observer_sg" {
  description = "Security Group of Observer"
}

variable "home_sg" {
  description = "Office people IP list"
}

variable "service_port" {
  description = "Service port"
}

variable "observer_port" {
  description = "Observer port"
}

variable "healthcheck_port" {
  description = "Healthcheck port"
}

variable "healthcheck_path" {
  description = "Healthcheck path"
}

variable "image_id" {
  description = "AMI ID for instance"
  type        = string
  default     = "ami-0662f4965dfc70aca"
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

variable "user_data_path" {
  description = "Path for user-data.sh"
}

variable "bastion_aware_sg" {
  description = "Allows ssh access from the bastion server"
}

variable "min_size" {
  description = "Auto Scaling min size"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Auto Scaling max size"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Auto Scaling desired capacity"
  type        = number
  default     = 1
}
