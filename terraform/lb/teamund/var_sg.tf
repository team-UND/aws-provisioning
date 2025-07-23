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

        beforegoingpapne2 = {
          Name    = "external-lb-sg-beforegoingp_apnortheast2"
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
          Name    = "internal-lb-sg-beforegoingp_apnortheast2"
          app     = "beforegoing"
          project = "beforegoing"
          env     = "prod"
          stack   = "beforegoingp_apnortheast2"
        }

      }
    }

  }
}
