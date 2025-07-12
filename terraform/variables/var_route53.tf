variable "r53_variables" {
  description = "Variables for Route53 configuration"

  type = object({

    dev = object({
      star_beforegoing_site_acm_arn_apnortheast2 = string
      beforegoing_site_zone_id                   = string
    })

  })

  default = {

    dev = {
      star_beforegoing_site_acm_arn_apnortheast2 = "arn:aws:acm:ap-northeast-2:116541189059:certificate/29f26588-557d-4bc4-afe8-8687cf83fac8"
      beforegoing_site_zone_id                   = "Z03269161XQ8EN5PTTGXB"
    }

  }
}
