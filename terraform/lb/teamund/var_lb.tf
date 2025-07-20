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
