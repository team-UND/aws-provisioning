variable "pg_variables" {
  description = "Parameter group variables for the DB"

  type = object({

    parameters = map(

      list(

        object({
          name  = string
          value = string
        })

      )

    )

  })

  default = {

    parameters = {

      beforegoingdapne1 = [
        {
          name  = "cluster-enabled"
          value = "no"
        },
        {
          name  = "maxmemory-policy"
          value = "volatile-lru"
        }
      ]

      beforegoingsapne2 = [
        {
          name  = "cluster-enabled"
          value = "no"
        },
        {
          name  = "maxmemory-policy"
          value = "volatile-lru"
        }
      ]

      beforegoingpapne2 = [
        {
          name  = "cluster-enabled"
          value = "no"
        },
        {
          name  = "maxmemory-policy"
          value = "volatile-lru"
        }
      ]

    }

  }
}
