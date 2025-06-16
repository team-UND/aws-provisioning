output "codedeploy_artifact_bucket_arn" {
  description = "ARN of the S3 bucket for CodeDeploy artifacts"
  value       = aws_s3_bucket.codedeploy_artifact.arn
}
