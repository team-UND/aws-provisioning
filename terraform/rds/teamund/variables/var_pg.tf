variable "pg_variables" {
  description = "Parameter group variables for the DB"

  type = object({
    parameters = map(list(object({
      name         = string
      value        = string
      apply_method = string
    })))
  })

  default = {

    parameters = {

      beforegoingdapne2 = [
        {
          name         = "time_zone"
          value        = "Asia/Seoul"
          apply_method = "pending-reboot"
        },
        {
          name         = "character_set_server"
          value        = "utf8mb4"
          apply_method = "pending-reboot"
        },
        {
          name         = "wait_timeout"
          value        = "1200"
          apply_method = "immediate"
        }
      ]

    }

  }
}
