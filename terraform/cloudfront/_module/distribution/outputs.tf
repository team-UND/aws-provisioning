output "aws_cloudfront_distribution_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.default.domain_name
}

output "aws_cloudfront_distribution_hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for the CloudFront distribution."
  value       = aws_cloudfront_distribution.default.hosted_zone_id
}
