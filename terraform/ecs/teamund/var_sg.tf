variable "sg_variables" {
  description = "Security group variables for the ECS cluster"

  type = object({

    ec2 = object({
      tags = map(map(string))
    })

  })

  default = {

    ec2 = {
      tags = {

        beforegoingpapne2 = {
          Name    = "ec2-sg-beforegoingp_apnortheast2"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "prod"
          stack   = "beforegoingp_apnortheast2"
        }

      }
    }

  }
}
