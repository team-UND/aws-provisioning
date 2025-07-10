output "aws_route53_zone_beforegoing_site_name" {
  description = "The internal domain name for the DB"
  value       = aws_route53_zone.beforegoing_site.name
}
