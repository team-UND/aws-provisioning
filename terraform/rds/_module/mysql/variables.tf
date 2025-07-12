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
  description = "The version of the MySQL engine to use"
  type        = string
}

variable "auto_minor_version_upgrade" {
  description = "Whether to allow minor version upgrades"
  type        = bool
}

variable "instance_class" {
  description = "The instance class to use"
  type        = string
}

variable "allocated_storage" {
  description = "The amount of storage to allocate"
  type        = number
}

variable "max_allocated_storage" {
  description = "The maximum amount of storage to allocate"
  type        = number
}

variable "storage_type" {
  description = "The storage type to use"
  type        = string
}

variable "username" {
  description = "Username for DB"
  type        = string
}

variable "db_name" {
  description = "Name of DB"
  type        = string
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = number
}

variable "manage_master_user_password" {
  description = "Whether to manage the master user password"
  type        = bool
}

variable "multi_az" {
  description = "Whether to use multi-AZ"
  type        = bool
}

variable "publicly_accessible" {
  description = "Whether the DB is publicly accessible"
  type        = bool
}

variable "backup_retention_period" {
  description = "The number of days to retain backups"
  type        = number
}

variable "copy_tags_to_snapshot" {
  description = "Whether to copy tags to snapshots"
  type        = bool
}

variable "enabled_cloudwatch_logs_exports" {
  description = "A list of log types to enable for exporting to CloudWatch Logs"
  type        = list(string)
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot when deleting the DB instance"
  type        = bool
}

variable "family" {
  description = "The family of the DB parameter group"
  type        = string
}
