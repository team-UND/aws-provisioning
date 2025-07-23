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

        beforegoingpapne2 = {
          Name    = "external-lb-beforegoingp_apnortheast2"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "prod"
          stack   = "beforegoingp_apnortheast2"
        }

      }
    }

    internal = {
      tags = {

        beforegoingpapne2 = {
          Name    = "internal-lb-beforegoingp_apnortheast2"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "prod"
          stack   = "beforegoingp_apnortheast2"
        }

      }
    }

  }
}
