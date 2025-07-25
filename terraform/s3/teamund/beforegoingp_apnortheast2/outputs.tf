output "aws_s3_bucket_id" {
  description = "The ID of the S3 bucket"
  value       = module.cloudfront_logs.aws_s3_bucket_id
}

output "aws_s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.cloudfront_logs.aws_s3_bucket_arn
}

output "aws_s3_bucket_bucket_domain_name" {
  description = "The domain name of the S3 bucket"
  value       = module.cloudfront_logs.aws_s3_bucket_bucket_domain_name
}

output "aws_s3_bucket_lifecycle_configuration_rule_prefix" {
  description = "The prefix for CloudFront access logs, derived from the lifecycle rule"
  value       = one(aws_s3_bucket_lifecycle_configuration.cloudfront_logs.rule).filter[0].prefix
}
