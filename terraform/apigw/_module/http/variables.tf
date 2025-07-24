variable "vpc_id" {
  description = "The AWS ID of the VPC this shard is being deployed into"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "shard_id" {
  description = "Shard ID for the VPC"
  type        = string
}

variable "lb_security_group_id" {
  description = "The ID of the security group for the internal load balancer"
  type        = string
}

variable "private_subnet_ids" {
  description = "A comma-delimited list of private subnets for the VPC"
  type        = list(string)
}

variable "lb_route_key" {
  description = "The route key for the default route that forwards to the load balancer"
  type        = string
}

variable "lambda_integrations" {
  description = "A map of Lambda integrations. The key is a logical name, and the value is an object with 'arn' and 'route_key'"
  type = map(
    object({
      arn       = string
      route_key = string
    })
  )
}

variable "cors_allow_origins" {
  description = "A list of allowed origins for CORS"
  type        = list(string)
}

variable "cors_allow_methods" {
  description = "A list of allowed methods for CORS"
  type        = list(string)
}

variable "cors_allow_headers" {
  description = "A list of allowed headers for CORS"
  type        = list(string)
}

variable "lb_listener_arn" {
  description = "ARN of the load balancer listener to integrate with API Gateway"
  type        = string
}

variable "throttling_burst_limit" {
  description = "The burst limit for throttling"
  type        = number
}

variable "throttling_rate_limit" {
  description = "The rate limit for throttling"
  type        = number
}

variable "log_group_name" {
  description = "The name of the CloudWatch log group for API Gateway access logs"
  type        = string
}

variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group"
  type        = number
}
