variable "lb_variables" {
  description = "Health check configuration variables for the App Runner service"

  type = object({

    health_check = object({
      protocol            = string
      path                = string
      interval            = number
      timeout             = number
      healthy_threshold   = number
      unhealthy_threshold = number
    })

  })

  default = {

    health_check = {
      protocol            = "HTTP"
      path                = "/server/actuator/health"
      interval            = 20
      timeout             = 20
      healthy_threshold   = 3
      unhealthy_threshold = 2
    }

  }
}
