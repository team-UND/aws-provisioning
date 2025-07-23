# Region
output "aws_region" {
  description = "Region of VPC"
  value       = var.aws_region
}

output "region_namespace" {
  description = "Region name without '-'"
  value       = replace(var.aws_region, "-", "")
}

# Availability zones
output "availability_zones" {
  description = "Availability zone list of VPC"
  value       = var.availability_zones
}

# VPC
output "vpc_name" {
  description = "The name of the VPC which is also the environment name"
  value       = var.vpc_name
}

output "vpc_id" {
  description = "VPC ID of newly created VPC"
  value       = aws_vpc.default.id
}

output "vpc_cidr_block" {
  description = "CIDR block of VPC"
  value       = aws_vpc.default.cidr_block
}

output "cidr_numeral" {
  description = "The number that specifies the vpc range (B class)"
  value       = var.cidr_numeral
}

# Shard
output "shard_id" {
  description = "The shard ID which will be used to distinguish the env of resources"
  value       = var.shard_id
}

# Public subnets
output "public_subnet_ids" {
  description = "List of public subnet ID in VPC"
  value       = aws_subnet.public[*].id
}

# Private subnets
output "private_subnet_ids" {
  description = "List of private subnet ID in VPC"
  value       = aws_subnet.private[*].id
}

# Private DB subnets
output "private_db_subnet_ids" {
  description = "List of DB private subnet ID in VPC"
  value       = aws_subnet.private_db[*].id
}

# Observability private subnets
output "private_observability_subnet_ids" {
  description = "List of private observability subnet ID in VPC"
  value       = aws_subnet.private_observability[*].id
}

output "private_observability_subnet_cidrs" {
  description = "CIDR blocks for the private observability subnets"
  value       = aws_subnet.private_observability[*].cidr_block
}

# Route53
output "route53_internal_domain_name" {
  description = "Internal domain name for VPC"
  value       = aws_route53_zone.internal.name
}

output "route53_internal_zone_id" {
  description = "Internal zone ID for VPC"
  value       = aws_route53_zone.internal.id
}

output "aws_security_group_default_id" {
  description = "ID of default security group"
  value       = aws_security_group.default.id
}

# ETC
output "env_suffix" {
  description = "Suffix of the environment"
  value       = var.env_suffix
}

output "billing_tag" {
  description = "The environment value for biliing consolidation."
  value       = var.billing_tag
}
