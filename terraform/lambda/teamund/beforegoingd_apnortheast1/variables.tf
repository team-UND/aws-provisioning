variable "authorizer_function_name" {
  description = "Name of the authorizer Lambda function"
  type        = string
}

variable "authorizer_runtime" {
  description = "Runtime for the authorizer Lambda function"
  type        = string
}

variable "authorizer_timeout" {
  description = "Timeout for the authorizer Lambda function"
  type        = number
}

variable "authorizer_memory_size" {
  description = "Memory size for the authorizer Lambda function"
  type        = number
}
