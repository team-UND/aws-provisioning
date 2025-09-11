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

variable "sentry_function_name" {
  description = "Name of the sentry Lambda function"
  type        = string
}

variable "sentry_runtime" {
  description = "Runtime for the sentry Lambda function"
  type        = string
  default     = "python3.12"
}

variable "sentry_timeout" {
  description = "Timeout for the sentry Lambda function"
  type        = number
}

variable "sentry_memory_size" {
  description = "Memory size for the sentry Lambda function"
  type        = number
}
