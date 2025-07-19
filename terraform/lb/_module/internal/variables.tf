variable "vpc_id" {
  description = "The AWS ID of the VPC this shard is being deployed into"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "shard_id" {
  description = "Shard ID for the VPC"
  type        = string
}

variable "lb_egress_cidr" {
  description = "Egress of security group of load balancer"
  type        = string
}

variable "lb_type" {
  description = "Type of load balancer to create (application, network, gateway)"
  type        = string
}

variable "private_subnet_ids" {
  description = "A comma-delimited list of private subnets for the VPC"
  type        = list(string)
}
