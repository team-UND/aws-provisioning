variable "sg_variables" {
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
