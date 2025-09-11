output "cloudfront_aws_wafv2_web_acl_arn" {
  description = "The ARN of the WAF Web ACL for CloudFront"
  value       = module.cloudfront.aws_wafv2_web_acl_arn
}
