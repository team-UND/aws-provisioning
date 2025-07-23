variable "lb_variables" {
  description = "Variables for the LB"

  type = object({

    external = object({
      tags = map(map(string))
    })

  })

  default = {

    external = {
      tags = {}
    }

  }
}
