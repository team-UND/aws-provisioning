variable "shard_id" {
  description = "Shard ID for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "vpc_id" {
  description = "The AWS ID of the VPC this shard is being deployed into"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  type        = string
}

variable "load_balancer_type" {
  description = "Type of load balancer to create (application, network, gateway)"
  type        = string
  default     = "application"
}

variable "lb_ingress_cidrs" {
  description = "Ingress of security group of load balancer"
  type        = string
}

variable "public_subnet_ids" {
  description = "A comma-delimited list of public subnets for the VPC"
  type        = list(string)
}

variable "acm_external_ssl_certificate_arn" {
  description = "ssl cert id"
  type        = string
}
