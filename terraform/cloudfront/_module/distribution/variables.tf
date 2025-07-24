variable "domain_name" {
  description = "The domain name for the CloudFront distribution"
  type        = string
}

variable "comment" {
  description = "A comment to describe the distribution"
  type        = string
}

variable "default_root_object" {
  description = "The default root object for the distribution"
  type        = string
}

variable "price_class" {
  description = "The price class for this distribution. Valid values are PriceClass_All, PriceClass_200, and PriceClass_100"
  type        = string
}

variable "aliases" {
  description = "A list of CNAMEs for this distribution"
  type        = list(string)
}

variable "origin_domain_name" {
  description = "The domain name of the origin (e.g., API Gateway invoke URL)"
  type        = string
}

variable "origin_path" {
  description = "An optional path that CloudFront appends to the origin domain name"
  type        = string
}

variable "origin_id" {
  description = "A unique identifier for the origin"
  type        = string
}

variable "origin_verify_secret_name" {
  description = "The name of the Secrets Manager secret containing the X-Origin-Verify header value."
  type        = string
}

variable "cache_policy_id" {
  description = "The ID of the cache policy to use for this distribution"
  type        = string
}

variable "origin_request_policy_id" {
  description = "The ID of the origin request policy to use for this distribution"
  type        = string
}

variable "geo_restriction_type" {
  description = "The method to restrict distribution of your content by country: none, whitelist, or blacklist"
  type        = string
}

variable "geo_restriction_locations" {
  description = "A list of ISO 3166-1-alpha-2 country codes for the geo restriction"
  type        = list(string)
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate for the custom domain"
  type        = string
}

variable "web_acl_id" {
  description = "The ARN of the WAFv2 Web ACL to associate with this distribution"
  type        = string
}

variable "log_bucket" {
  description = "The S3 bucket for CloudFront access logs"
  type        = string
}

variable "log_bucket_prefix" {
  description = "The prefix for the CloudFront access logs in the S3 bucket"
  type        = string
}