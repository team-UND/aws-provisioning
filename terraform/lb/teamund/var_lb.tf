variable "lb_variables" {
  description = "Variables for the LB"

  type = object({

    external = object({
      tags = map(map(string))
    })

    internal = object({
      tags = map(map(string))
    })

  })

  default = {

    external = {
      tags = {

        beforegoingsapne2 = {
          Name    = "ext-lb-beforegoings_apnortheast2"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "stg"
          stack   = "beforegoings_apnortheast2"
        }

        beforegoingpapne2 = {
          Name    = "ext-lb-beforegoingp_apnortheast2"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "prod"
          stack   = "beforegoingp_apnortheast2"
        }

      }
    }

    internal = {
      tags = {

        beforegoingsapne2 = {
          Name    = "int-lb-beforegoings_apnortheast2"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "stg"
          stack   = "beforegoings_apnortheast2"
        }

        beforegoingpapne2 = {
          Name    = "int-lb-beforegoingp_apnortheast2"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "prod"
          stack   = "beforegoingp_apnortheast2"
        }

      }
    }

  }
}
