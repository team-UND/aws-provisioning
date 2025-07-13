variable "lb_variables" {
  description = "Variables for the LB"

  type = object({

    lb = object({
      tags = map(map(string))
    })

  })

  default = {

    lb = {
      tags = {

        beforegoingdapne2 = {
          Name    = "ext-lb-beforegoingd_apnortheast2"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "dev"
          stack   = "beforegoingd_apnortheast2"
        }

      }
    }

  }
}
