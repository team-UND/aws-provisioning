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

}
