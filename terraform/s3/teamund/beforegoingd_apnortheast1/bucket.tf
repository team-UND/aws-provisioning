resource "aws_s3_bucket_policy" "cloudfront_logs" {
  bucket = module.cloudfront_logs.aws_s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl"
        ],
        Resource = [
          "${module.cloudfront_logs.aws_s3_bucket_arn}/*", # For PutObject
          module.cloudfront_logs.aws_s3_bucket_arn         # For GetBucketAcl
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudfront_logs" {
  bucket = module.cloudfront_logs.aws_s3_bucket_id

  rule {
    id     = "log-expiration"
    status = "Enabled"

    filter {
      prefix = "api-access-logs/"
    }

    expiration {
      days = 30
    }
  }
}

module "cloudfront_logs" {
  source = "../../_module/bucket"

  shard_id      = data.terraform_remote_state.vpc.outputs.shard_id
  bucket_name   = "cloudfront-logs"
  force_destroy = true

  object_ownership        = "ObjectWriter"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
