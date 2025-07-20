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
      beforegoingpapne2 = 0
    }

    target_group_deregistration_delay = {
      beforegoingpapne2 = 0
    }

    lb_tg = {
      tags = {

        beforegoingpapne2 = {
          Name    = "internal-lb-tg-beforegoingp_apnortheast2"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "prod"
          stack   = "beforegoingp_apnortheast2"
        }

      }
    }

    health_check = {
      interval = {
        beforegoingpapne2 = 15
      }
      timeout = {
        beforegoingpapne2 = 5
      }
      healthy_threshold = {
        beforegoingpapne2 = 3
      }
      unhealthy_threshold = {
        beforegoingpapne2 = 2
      }
    }

  }
}
