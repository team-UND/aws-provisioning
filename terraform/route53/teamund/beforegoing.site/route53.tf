# AWS Route53 Zone
module "route53" {
  source = "../../_module/hosting_zone"

  route53_zone_name = "beforegoing.site"
}
