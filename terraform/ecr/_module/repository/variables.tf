variable "repository_name" {
  description = "The name of the ECR repository"
  type        = string
}

variable "create_lifecycle_policy" {
  description = "Whether to create a lifecycle policy for the repository"
  type        = bool
}

variable "untagged_image_expiration_days" {
  description = "Number of days after which to expire untagged images"
  type        = number
}

variable "tagged_image_retention_count" {
  description = "Number of tagged images to retain"
  type        = number
}

