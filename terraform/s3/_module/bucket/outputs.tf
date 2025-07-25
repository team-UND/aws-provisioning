output "aws_s3_bucket_id" {
  description = "The ID of the S3 bucket"
  value       = aws_s3_bucket.default.id
}

output "aws_s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.default.arn
}

output "aws_s3_bucket_bucket_domain_name" {
  description = "The domain name of the S3 bucket"
  value       = aws_s3_bucket.default.bucket_domain_name
}
