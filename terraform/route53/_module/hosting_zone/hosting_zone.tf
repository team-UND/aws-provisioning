# AWS Route53 Zone
resource "aws_route53_zone" "default" {
  name    = var.route53_zone_name
  comment = "HostedZone created by Route53 Registrar - Manged Terraform"
}
