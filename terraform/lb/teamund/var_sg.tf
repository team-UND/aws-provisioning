variable "sg_variables" {
  description = "Security group variables for the LB"

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
          Name    = "ext-lb-sg-beforegoings_apnortheast2"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "stg"
          stack   = "beforegoings_apnortheast2"
        }

        beforegoingpapne2 = {
          Name    = "ext-lb-sg-beforegoingp_apnortheast2"
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
          Name    = "int-lb-sg-beforegoings_apnortheast2"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "stg"
          stack   = "beforegoings_apnortheast2"
        }

        beforegoingpapne2 = {
          Name    = "int-lb-sg-beforegoingp_apnortheast2"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "prod"
          stack   = "beforegoingp_apnortheast2"
        }

      }
    }

  }
}
