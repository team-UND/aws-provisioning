variable "sg_variables" {
  type = object({

    ec2 = object({
      tags = map(map(string))
    })

    external_lb = object({
      tags = map(map(string))
    })

  })

  default = {

    ec2 = {
      tags = {}
    }

    external_lb = {
      tags = {}
    }

  }
}
