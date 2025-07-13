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
      tags = {

        beforegoingdapne2 = {
          Name    = "ec2-sg-beforegoingd_apnortheast2"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "dev"
          stack   = "beforegoingd_apnortheast2"
        }

      }
    }

    ext_lb = {
      tags = {

        beforegoingdapne2 = {
          Name    = "ext-lb-sg-beforegoingd_apnortheast2"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "dev"
          stack   = "beforegoingd_apnortheast2"
        }

      }
    }

  }
}
