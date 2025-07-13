variable "aws_region" {
  description = "AWS region to use"
  type        = string
}

variable "vpc_name" {
  description = "The unique VPC name this storage layer belongs to"
  type        = string
}

variable "vpc_config" {
  description = "VPC configuration for the Lambda function. If not provided, the function is not deployed into a VPC"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "shard_id" {
  description = "Shard ID for the VPC"
  type        = string
}

variable "billing_tag" {
  description = "The AWS tag used to track AWS charges"
  type        = string
}

variable "source_file_path" {
  description = "The path of the source file for the Lambda function code"
  type        = string
}

variable "output_path" {
  description = "The path to the Lambda function deployment package"
  type        = string
}

variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "handler" {
  description = "The function entrypoint in your code"
  type        = string
}

variable "role" {
  description = "The ARN of the IAM role that Lambda assumes when it executes the function"
  type        = string
}

variable "runtime" {
  description = "The runtime environment for the Lambda function"
  type        = string
}

variable "timeout" {
  description = "The amount of time that Lambda allows a function to run before stopping it"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "The amount of memory available to the function at runtime"
  type        = number
  default     = 128
}

variable "env_variables" {
  description = "A map of environment variables for the Lambda function"
  type        = map(string)
}

variable "lb_https_listener_arn" {
  description = "The ARN of the LB's HTTPS listener"
  type        = string
}

variable "listener_rule_priority" {
  description = "The priority for the listener rule. Must be unique per listener"
  type        = number
}

variable "domain_name" {
  description = "The domain name for the function, if applicable"
  type        = string
}

variable "route53_zone_id" {
  description = "The Route 53 zone ID for the domain"
  type        = string
}

variable "lb_dns_name" {
  description = "The DNS name of the LB"
  type        = string
}

variable "lb_zone_id" {
  description = "The zone ID of the LB"
  type        = string
}

variable "log_group_name" {
  description = "The name of the CloudWatch log group for the Lambda function"
  type        = string
}

variable "log_retention_in_days" {
  description = "The number of days to retain logs in CloudWatch"
  type        = number
  default     = 7
}
