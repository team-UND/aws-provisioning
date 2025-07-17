# variable "r53_variables" {
#   description = "Variables for Route53 configuration"

#   type = object({

#     dev = object({
#       star_beforegoing_store_acm_arn_apnortheast1 = string
#       beforegoing_store_zone_id                   = string
#     })

#     stg = object({
#       star_beforegoing_site_acm_arn_apnortheast2 = string
#       beforegoing_site_zone_id                   = string
#     })

#   })

#   default = {

#     dev = {
#       star_beforegoing_store_acm_arn_apnortheast1 = "arn:aws:acm:ap-northeast-1:116541189059:certificate/7147922d-10a1-48ed-accf-d1b8ef8f1274"
#       beforegoing_store_zone_id                   = "Z04155673ICLEIQY7TSNV"
#     }

#     stg = {
#       star_beforegoing_site_acm_arn_apnortheast2 = "arn:aws:acm:ap-northeast-2:116541189059:certificate/29f26588-557d-4bc4-afe8-8687cf83fac8"
#       beforegoing_site_zone_id                   = "Z0280803271OX6NLOI0MK"
#     }

#   }
# }
