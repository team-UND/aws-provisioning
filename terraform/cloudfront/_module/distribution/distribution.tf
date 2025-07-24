data "aws_acm_certificate" "default" {
  domain   = "*.${var.domain_name}"
  statuses = ["ISSUED"]
}

data "aws_secretsmanager_secret" "origin_verify" {
  name = var.origin_verify_secret_name
}

resource "aws_cloudfront_distribution" "default" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.comment
  default_root_object = var.default_root_object
  price_class         = var.price_class
  aliases             = var.aliases

  origin {
    domain_name = var.origin_domain_name
    origin_id   = var.origin_id
    origin_path = var.origin_path
  }

  dynamic "custom_header" {
    for_each = { "X-Origin-Verify" = data.aws_secretsmanager_secret.origin_verify.secret_string }
    content {
      name  = custom_header.key
      value = custom_header.value
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.origin_id

    cache_policy_id          = var.cache_policy_id
    origin_request_policy_id = var.origin_request_policy_id

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.default.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  web_acl_id = var.web_acl_id

  dynamic "logging_config" {
    for_each = var.log_bucket != null ? [var.log_bucket] : []

    content {
      include_cookies = false
      bucket          = logging_config.value
      prefix          = var.log_bucket_prefix
    }
  }
}
