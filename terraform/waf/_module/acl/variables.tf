variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "name" {
  description = "Name for the WAF Web ACL"
  type        = string
}

variable "scope" {
  description = "Specifies whether this is for an AWS CloudFront distribution or for a regional application"
  type        = string
}


variable "ip_set_rules" {
  description = "A map of IP set rules to apply. The key is the rule name. The value is an object containing the priority and the IP Set ARN"
  type = map(object({
    priority = number
    arn      = string
  }))
}

variable "rate_limit" {
  description = "The maximum number of requests from a single IP address in a 5-minute period. You you want to disable, set to 0"
  type        = number
}

variable "enable_ip_reputation_rule" {
  description = "Enable AWSManagedRulesAmazonIpReputationList. This blocks IPs known for bot or threat activity."
  type        = bool
  default     = true
}

variable "enable_common_rule_set" {
  description = "Enable AWSManagedRulesCommonRuleSet. This protects against common exploits like SQLi and XSS."
  type        = bool
  default     = true
}

variable "common_rule_set_exceptions" {
  description = "List of path exceptions for Common Rule Set with specific rule overrides"
  type = list(object({
    path       = string # Path to match (ex. "/sentry")
    match_type = string # Matching type: "EXACTLY" "STARTS_WITH" "ENDS_WITH" "CONTAINS" "CONTAINS_WORD"
    rule_name  = string # AWS managed rule name to override (ex. "SizeRestrictions_BODY")
  }))
}
