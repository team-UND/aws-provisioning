variable "lb_variables" {
  description = "Variables for the LB"

  type = object({

    target_group_slow_start = map(number)

    target_group_deregistration_delay = map(number)

    lb_tg = object({
      tags = map(map(string))
    })

    health_check = object({
      interval            = map(number)
      timeout             = map(number)
      healthy_threshold   = map(number)
      unhealthy_threshold = map(number)
    })
  })

  default = {

    target_group_slow_start = {
      beforegoingdapne2 = 0
    }

    target_group_deregistration_delay = {
      beforegoingdapne2 = 0
    }

    lb_tg = {
      tags = {

        beforegoingdapne2 = {
          Name    = "ext-lb-tg-beforegoingd_apnortheast2"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "dev"
          stack   = "beforegoingd_apnortheast2"
        }

      }
    }

    health_check = {
      interval = {
        beforegoingdapne2 = 15
      }
      timeout = {
        beforegoingdapne2 = 5
      }
      healthy_threshold = {
        beforegoingdapne2 = 3
      }
      unhealthy_threshold = {
        beforegoingdapne2 = 2
      }
    }

  }
}
