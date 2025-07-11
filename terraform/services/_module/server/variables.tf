variable "aws_region" {
  description = "AWS region to use"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "vpc_id" {
  description = "The AWS ID of the VPC this shard is being deployed into"
  type        = string
}

variable "shard_id" {
  description = "Shard ID for the VPC"
  type        = string
}

variable "ecs_cluster_id" {
  description = "The ID of the shared ECS cluster"
  type        = string
}

variable "ecs_cluster_name" {
  description = "The name of the shared ECS cluster"
  type        = string
}

variable "service_name" {
  description = "The name of this service"
  type        = string
}

variable "service_port" {
  description = "Service port"
  type        = number
}

variable "health_check_port" {
  description = "Healthcheck port"
  type        = number
}

variable "health_check_path" {
  description = "Healthcheck path"
  type        = string
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on a new task. Gives the container time to start"
  type        = number
  default     = 60
}

variable "ecs_capacity_provider_name" {
  description = "The name of the ECS capacity provider to use for the service"
  type        = string
}

variable "subnet_ids" {
  description = "A comma-delimited list of subnets for the VPC"
  type        = list(string)
}

variable "domain_name" {
  description = "Domain Name"
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

variable "lb_security_group_id" {
  description = "The security group ID of the LB"
  type        = string
}

variable "container_desired_capacity" {
  description = "Default number of containers to run for the service"
  type        = number
  default     = 1
}

variable "container_min_capacity" {
  description = "Minimum number of containers to run for the service"
  type        = number
  default     = 1
}

variable "container_max_capacity" {
  description = "Maximum number of containers to run for the service"
  type        = number
  default     = 2
}

variable "target_value" {
  description = "Target average CPU utilization for the service. The autoscaler will adjust the number of containers to maintain this target"
  type        = number
  default     = 80 # Target 80% average CPU utilization
}

variable "scale_in_cooldown" {
  description = "Cooldown period after scaling in before allowing another scale in action"
  type        = number
  default     = 180 # 3 minutes before scaling in
}

variable "scale_out_cooldown" {
  description = "Cooldown period after scaling out before allowing another scale out action"
  type        = number
  default     = 60 # 1 minute before scaling out again
}

variable "task_cpu" {
  description = "The number of CPU units to reserve for the container. 1024 is 1 vCPU"
  type        = string
  default     = "256" # 0.25 vCPU
}

variable "task_memory_hard_limit" {
  description = "The absolute maximum amount of memory (in MiB) the task can use. This is a hard limit. Set to null to have no limit"
  type        = string
  default     = "256" # 256 MiB
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of the IAM role for ECS task execution. Allows pulling images from ECR and sending logs to CloudWatch"
  type        = string
}

variable "container_definitions_json" {
  description = "A fully-rendered JSON string of container definitions for the task"
  type        = string
}

variable "lb_https_listener_arn" {
  description = "The ARN of the LB's HTTPS listener"
  type        = string
}

variable "listener_rule_priority" {
  description = "The priority for the listener rule. Must be unique per listener"
  type        = number
}

variable "route53_zone_id" {
  description = "The ID of the Route 53 Hosted Zone"
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
