variable "vpc_id" {
  description = "The AWS ID of the VPC this shard is being deployed into"
  type        = string
}

variable "shard_id" {
  description = "The shard ID which will be used to distinguish the env of resources"
  type        = string
}

variable "subnet_ids" {
  description = "A comma-delimited list of subnets for the VPC"
  type        = list(string)
}

variable "route53_zone_id" {
  description = "The ID of the Route 53 Hosted Zone"
  type        = string
}

variable "domain_name" {
  description = "Domain Name"
  type        = string
}

variable "engine_version" {
  description = "The version of the Redis engine to use"
  type        = string
}

variable "auto_minor_version_upgrade" {
  description = "Whether to allow minor version upgrades"
  type        = bool
}

variable "node_type" {
  description = "The instance class to use"
  type        = string
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = number
}

variable "num_cache_clusters" {
  description = "The number of cache clusters in the replication group"
  type        = number
}

variable "multi_az_enabled" {
  description = "Whether to use multi-AZ"
  type        = bool
}

variable "automatic_failover_enabled" {
  description = "Whether to enable automatic failover"
  type        = bool
}

variable "family" {
  description = "The family of the DB parameter group"
  type        = string
}
