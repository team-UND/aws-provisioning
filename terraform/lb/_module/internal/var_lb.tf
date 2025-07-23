variable "lb_variables" {
  description = "Variables for the LB"

  type = object({

    internal = object({
      tags = map(map(string))
    })

  })

  default = {

    internal = {
      tags = {}
    }

  }
}
