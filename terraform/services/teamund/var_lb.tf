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
      beforegoingsapne2 = 0
      beforegoingpapne2 = 0
    }

    target_group_deregistration_delay = {
      beforegoingsapne2 = 0
      beforegoingpapne2 = 0
    }

    lb_tg = {
      tags = {

        beforegoingsapne2 = {
          Name    = "int-lb-tg-beforegoings_apnortheast2"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "stg"
          stack   = "beforegoings_apnortheast2"
        }

        beforegoingpapne2 = {
          Name    = "int-lb-tg-beforegoingp_apnortheast2"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "prod"
          stack   = "beforegoingp_apnortheast2"
        }

      }
    }

    health_check = {
      interval = {
        beforegoingsapne2 = 15
        beforegoingpapne2 = 15
      }
      timeout = {
        beforegoingsapne2 = 5
        beforegoingpapne2 = 5
      }
      healthy_threshold = {
        beforegoingsapne2 = 3
        beforegoingpapne2 = 3
      }
      unhealthy_threshold = {
        beforegoingsapne2 = 2
        beforegoingpapne2 = 2
      }
    }

  }
}
