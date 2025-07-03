variable "lb_variables" {
  default = {

    target_group_slow_start = {
      beforegoingdapne2 = 0
    }

    target_group_deregistration_delay = {
      beforegoingdapne2 = 0
    }

    external_lb = {
      tags = {

        beforegoingdapne2 = {
          Name    = "beforegoingd_apnortheast2-external-lb"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "dev"
          stack   = "beforegoingd_apnortheast2"
        }

      }
    }

    external_lb_tg = {
      tags = {

        beforegoingdapne2 = {
          Name    = "beforegoingd_apnortheast2-external-tg"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "dev"
          stack   = "beforegoingd_apnortheast2"
        }

      }
    }
  }
}
