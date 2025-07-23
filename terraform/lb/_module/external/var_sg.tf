variable "sg_variables" {
  description = "Security group variables for the LB"

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
