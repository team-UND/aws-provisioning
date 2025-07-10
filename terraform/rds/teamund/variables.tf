variable "username" {
  description = "Username for DB"
  type        = string
}

variable "db_name" {
  description = "Name of DB"
  type        = string
}

variable "internal_domain_name" {
  description = "The internal domain name for the DB"
  type        = string
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = string
}
