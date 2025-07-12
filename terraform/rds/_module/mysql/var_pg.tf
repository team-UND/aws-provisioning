variable "pg_variables" {
  description = "Parameter group variables for the DB"

  type = object({

    parameters = map(

      list(

        object({
          name         = string
          value        = string
          apply_method = string
        })

      )

    )

  })

  default = {

    parameters = {}

  }
}
