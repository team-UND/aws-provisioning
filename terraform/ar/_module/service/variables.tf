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

variable "service_name" {
  description = "The name of this service"
  type        = string
}

variable "access_role_arn" {
  description = "The ARN of the IAM role that grants App Runner permission to access the image repository"
  type        = string
}

variable "image_uri" {
  description = "URI of the Docker image in ECR"
  type        = string
}

variable "image_tag" {
  description = "Tag of the Docker image to deploy"
  type        = string
}

variable "image_repository_type" {
  description = "Type of the image repository (ECR_PRIVATE or ECR_PUBLIC)"
  type        = string
}

variable "container_port" {
  description = "Port that the container listens on"
  type        = number
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type        = map(string)
}

variable "environment_secrets" {
  description = "Secrets from Secrets Manager to inject into the container"
  type        = map(string)
}

variable "auto_deploy" {
  description = "Whether to enable automatic deployments on new image pushes"
  type        = bool
}

variable "instance_role_arn" {
  description = "The ARN of the IAM role that provides permissions to the App Runner service instance"
  type        = string
}

variable "cpu" {
  description = "CPU configuration for the App Runner service"
  type        = string
}

variable "memory" {
  description = "Memory configuration for the App Runner service"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the VPC connector"
  type        = list(string)
}

variable "ar_egress_cidr" {
  description = "CIDR block for egress traffic from the App Runner"
  type        = string
}

variable "autoscaling_min_size" {
  description = "Minimum number of active instances for auto scaling"
  type        = number
}

variable "autoscaling_max_size" {
  description = "Maximum number of active instances for auto scaling"
  type        = number
}

variable "autoscaling_max_concurrency" {
  description = "Maximum number of concurrent requests per instance"
  type        = number
}

variable "domain_name" {
  description = "Domain Name"
  type        = string
}

variable "subdomain_name" {
  description = "Subdomain Name"
  type        = string
}

variable "enable_www_subdomain" {
  description = "Whether to enable the www subdomain for the service"
  type        = bool
}

variable "enable_observability" {
  description = "If true, enables AWS X-Ray tracing for the App Runner service"
  type        = bool
}
