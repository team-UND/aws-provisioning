variable "sg_variables" {
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
