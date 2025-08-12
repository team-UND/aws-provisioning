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

variable "target_security_group_id" {
  description = "The ID of the security group to which the VPC Link will send traffic"
  type        = string
}

variable "private_subnet_ids" {
  description = "A comma-delimited list of private subnets for the VPC"
  type        = list(string)
}

variable "authorizer_lambda_function_arn" {
  description = "The standard ARN of the Lambda function to be used as an authorizer. Required for setting permissions. If null, no authorizer is created"
  type        = string
}

variable "authorizer_lambda_invoke_arn" {
  description = "The invocation ARN of the Lambda function to be used as an authorizer. Required for the authorizer URI. If null, no authorizer is created"
  type        = string
}

variable "authorizer_result_ttl_in_seconds" {
  description = "The TTL for the authorizer result in seconds"
  type        = number
}

variable "origin_verify_header_name" {
  description = "The name of the header to use as the identity source for the authorizer"
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

variable "proxy_integration_uri" {
  description = "The ARN of the load balancer listener or the URL of the App Runner service to integrate with API Gateway"
  type        = string
}

variable "proxy_route_key" {
  description = "The route key for the default proxy integration (ex. ANY /{proxy+})"
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
