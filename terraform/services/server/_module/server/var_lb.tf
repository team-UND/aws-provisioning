variable "lb_variables" {
  default = {

    target_group_slow_start = {}

    health_check_interval = {}

    target_group_deregistration_delay = {}

    external_lb_tg = {
      tags = {}
    }

  }
}
