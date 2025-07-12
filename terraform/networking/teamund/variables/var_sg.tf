variable "sg_variables" {
  description = "Security group variables for the LB"

  type = object({

    lb = object({
      tags = map(map(string))
    })

  })

  default = {

    lb = {
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
