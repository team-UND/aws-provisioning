variable "sg_variables" {
  description = "Security group variables for the ECS cluster"

  type = object({

    ec2 = object({
      tags = map(map(string))
    })

    ext_lb = object({
      tags = map(map(string))
    })

  })

  default = {

    ec2 = {
      tags = {}
    }

    ext_lb = {
      tags = {}
    }

  }
}
