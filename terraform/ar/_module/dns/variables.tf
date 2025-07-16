variable "certificate_validation_records" {
  description = "Validation records for the certificate"
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
}

variable "dns_target" {
  description = "DNS target for the App Runner service"
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 zone ID for DNS records"
  type        = string
}

variable "subdomain_name" {
  description = "Subdomain name for the App Runner service"
  type        = string
}
