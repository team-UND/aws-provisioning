variable "service_name" {
  description = "The name of this service"
}

# For new shards, this should only be the shard ID and must not include the AWS region
# For example, use apne2, not ap-northeast-2
variable "shard_id" {
  description = "Text used to identify shard of infrastructure components"
}

variable "aws_region" {
  description = "The AWS region to deploy the shard storage layer into"
}

variable "vpc_name" {
  description = "The unique VPC name this storage layer belongs to"
}

variable "vpc_id" {
  description = "The AWS ID of the VPC this shard is being deployed into"
}

variable "availability_zone" {
  description = "A comma-delimited list of availability zones for the VPC"
  default     = "ap-northeast-2a"
}

variable "public_subnet_ids" {
  description = "A comma-delimited list of public subnets for the VPC"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "A comma-delimited list of private subnets for the VPC"
  type        = list(string)
}

variable "billing_tag" {
  description = "The shard's default billing tag"
}

variable "route53_external_zone_id" {
  description = "r53 zone id"
}

variable "domain_name" {
  description = "Domain Name"
}

variable "acm_external_ssl_certificate_arn" {
  description = "ssl cert id"
}

variable "ext_lb_ingress_cidrs" {
  description = "Ingress of security group of external load balancer"
}

variable "observer_sg" {
  description = "Security Group of Observer"
}

variable "home_sg" {
  description = "Office people IP list"
}

variable "service_port" {
  description = "Service port"
}

variable "observer_port" {
  description = "Observer port"
}

variable "healthcheck_port" {
  description = "Healthcheck port"
}

variable "healthcheck_path" {
  description = "Healthcheck path"
}

variable "instance_type" {
  description = "EC2 Instance type"
  type        = string
  default     = "t2.micro"
}

variable "private_ec2_key_name" {
  description = "Private EC2 key-pair"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "Name of IAM instance profile"
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of the IAM role for ECS task execution. Allows pulling images from ECR and sending logs to CloudWatch."
  type        = string
}

variable "bastion_aware_sg" {
  description = "Allows ssh access from the bastion server"
}

variable "ec2_min_size" {
  description = "Auto Scaling min size"
  type        = number
  default     = 1
}

variable "ec2_max_size" {
  description = "Auto Scaling max size"
  type        = number
  default     = 2
}

variable "ec2_desired_capacity" {
  description = "Auto Scaling desired capacity"
  type        = number
  default     = 1
}

variable "task_cpu" {
  description = "The number of CPU units to reserve for the container. 1024 is 1 vCPU."
  type        = string
  default     = "256" # 0.25 vCPU
}

variable "task_memory" {
  description = "The amount of memory (in MiB) to reserve for the container."
  type        = string
  default     = "512" # 512 MiB
}

variable "container_image_url" {
  description = "The URL of the container image to use for the service."
  type        = string
}

variable "prometheus_image_url" {
  description = "The URL of the Prometheus container image to use for the sidecar."
  type        = string
  default     = "prom/prometheus:latest"
}

variable "container_desired_capacity" {
  description = "Default number of containers to run for the service."
  type        = number
  default     = 1
}

variable "container_min_capacity" {
  description = "Minimum number of containers to run for the service."
  type        = number
  default     = 1
}

variable "container_max_capacity" {
  description = "Maximum number of containers to run for the service."
  type        = number
  default     = 2
}

variable "target_value" {
  type    = number
  default = 80 # Target 80% average CPU utilization
}

variable "scale_in_cooldown" {
  type    = number
  default = 300 # 5 minutes before scaling in
}

variable "scale_out_cooldown" {
  type    = number
  default = 60 # 1 minute before scaling out again
}
