variable "aws_region" {
  description = "AWS region where Resource Explorer is deployed"
  type        = string
}

variable "filter_string" {
  description = "Filter string for the Resource Explorer view"
  type        = string
}

variable "default_view" {
  description = "Indicates if this view should be the default view"
  type        = bool
}
