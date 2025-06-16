# AWS Route53 Zone 
resource "aws_route53_zone" "beforegoing_site" {
  name    = "beforegoing.site"
  comment = "HostedZone created by Route53 Registrar - Manged Terraform"
}
