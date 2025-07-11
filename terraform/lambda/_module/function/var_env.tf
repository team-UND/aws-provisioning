variable "env_variables" {
  type = object({
    lambda = map(map(string))
  })

  default = {

    lambda = {}

  }
}
