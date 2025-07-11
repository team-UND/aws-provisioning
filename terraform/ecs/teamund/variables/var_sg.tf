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
      tags = {

        beforegoingdapne2 = {
          Name    = "beforegoingd_apnortheast2-ec2-sg"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "dev"
          stack   = "beforegoingd_apnortheast2"
        }

      }
    }

    external_lb = {
      tags = {

        beforegoingdapne2 = {
          Name    = "beforegoingd_apnortheast2-external-lb-sg"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "dev"
          stack   = "beforegoingd_apnortheast2"
        }

      }
    }

  }
}
