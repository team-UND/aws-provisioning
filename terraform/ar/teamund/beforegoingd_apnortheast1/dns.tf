module "dns" {
  source = "../../_module/dns"

  certificate_validation_records = module.service.aws_apprunner_custom_domain_association_certificate_validation_records
  dns_target                     = module.service.aws_apprunner_custom_domain_association_dns_target
  route53_zone_id                = data.terraform_remote_state.hosting_zone.outputs.aws_route53_zone_id
  subdomain_name                 = var.subdomain_name
}
