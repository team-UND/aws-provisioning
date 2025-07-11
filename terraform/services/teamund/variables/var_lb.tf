variable "lb_variables" {
  type = object({

    target_group_slow_start = map(number)

    health_check_interval = map(number)

    target_group_deregistration_delay = map(number)

    lb_tg = object({
      tags = map(map(string))
    })

  })

  default = {

    target_group_slow_start = {
      beforegoingdapne2 = 0
    }

    health_check_interval = {
      beforegoingdapne2 = 20
    }

    target_group_deregistration_delay = {
      beforegoingdapne2 = 0
    }

    lb_tg = {
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
