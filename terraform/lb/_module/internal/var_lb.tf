variable "lb_variables" {
  description = "Variables for the LB"

  type = object({

    lb = object({
      tags = map(map(string))
    })

  })

  default = {

    lb = {
      tags = {}
    }

  }
}
