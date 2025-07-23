variable "sg_variables" {
  description = "Security group variables for the LB"

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
