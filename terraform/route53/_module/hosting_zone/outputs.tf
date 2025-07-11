output "aws_route53_zone_name" {
  description = "The name of the Route53 zone to create"
  value       = aws_route53_zone.default.name
}
