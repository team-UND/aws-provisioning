variable "lb_variables" {
  default = {

    external_lb = {
      tags = {

        beforegoingdapne2 = {
          Name    = "beforegoingd_apnortheast2-external-lb"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "dev"
          stack   = "beforegoingd_apnortheast2"
        }

      }
    }

  }
}
