variable "aws_region" {
  description = "The AWS region to deploy the shard storage layer into"
  type        = string
}

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

variable "lb_ingress_cidrs" {
  description = "A map of CIDR blocks to allow for ingress traffic. The keys are for description only"
  type        = map(string)
}

variable "lb_egress_cidr" {
  description = "CIDR block for egress traffic from the LB"
  type        = string
}

variable "lb_type" {
  description = "Type of the LB to create (application, network, gateway)"
  type        = string
}

variable "public_subnet_ids" {
  description = "A comma-delimited list of public subnets for the VPC"
  type        = list(string)
}

variable "route53_zone_id" {
  description = "The ID of the Route 53 Hosted Zone"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the External LB"
  type        = string
}

variable "subdomain_name" {
  description = "Subdomain name for the External LB"
  type        = string
}
