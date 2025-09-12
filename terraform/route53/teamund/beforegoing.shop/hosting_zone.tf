# AWS Route53 Zone
module "hosting_zone" {
  source = "../../_module/hosting_zone"

  route53_zone_name = var.route53_zone_name
}
