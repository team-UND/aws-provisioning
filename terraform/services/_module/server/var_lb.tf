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

    target_group_slow_start = {}

    target_group_deregistration_delay = {}

    lb_tg = {
      tags = {}
    }

    health_check = {
      interval            = {}
      timeout             = {}
      healthy_threshold   = {}
      unhealthy_threshold = {}
    }
  }
}
