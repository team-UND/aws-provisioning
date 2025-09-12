output "regional_aws_wafv2_web_acl_arn" {
  description = "The ARN of the WAF Web ACL for regional"
  value       = module.regional.aws_wafv2_web_acl_arn
}
