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

    target_group_slow_start = {}

    health_check_interval = {}

    target_group_deregistration_delay = {}

    lb_tg = {
      tags = {}
    }

  }
}
