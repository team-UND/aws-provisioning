variable "sg_variables" {
  description = "Security group variables for the LB"

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
