output "aws_route53_zone_id" {
  description = "The ID of the Route53 zone to create"
  value       = module.hosting_zone.aws_route53_zone_id
}

output "aws_route53_zone_name" {
  description = "The name of the Route53 zone to create"
  value       = module.hosting_zone.aws_route53_zone_name
}
