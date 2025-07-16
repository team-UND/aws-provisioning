resource "aws_route53_record" "certificate_validation" {
  for_each = {
    for r in var.certificate_validation_records : r.name => r
  }

  zone_id         = var.route53_zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 300
  records         = [each.value.value]
  allow_overwrite = true
}

resource "aws_route53_record" "ar_domain" {
  zone_id = var.route53_zone_id
  name    = var.subdomain_name
  type    = "CNAME"
  ttl     = 300
  records = [var.dns_target]
}
