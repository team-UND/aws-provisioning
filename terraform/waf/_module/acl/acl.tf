resource "aws_wafv2_web_acl" "default" {
  name  = "${var.name}-${var.vpc_name}"
  scope = var.scope

  default_action {
    allow {}
  }

  # Define rules for blocking specific IP addresses
  dynamic "rule" {
    for_each = var.ip_set_rules

    content {
      name     = rule.key
      priority = rule.value.priority

      action {
        block {}
      }

      statement {
        ip_set_reference_statement {
          arn = rule.value.arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-${rule.key}"
        sampled_requests_enabled   = true
      }
    }
  }

  # Define rules for rate limiting requests from IP addresses
  dynamic "rule" {
    for_each = var.rate_limit > 0 ? { "RateLimitRule" : var.rate_limit } : {}

    content {
      name     = rule.key
      priority = 10

      action {
        block {}
      }

      statement {
        rate_based_statement {
          limit              = rule.value
          aggregate_key_type = "IP"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-${rule.key}"
        sampled_requests_enabled   = true
      }
    }
  }

  # AWS Managed Rule: Amazon IP Reputation List
  dynamic "rule" {
    for_each = var.enable_ip_reputation_rule ? ["AWSManagedRulesAmazonIpReputationList"] : []

    content {
      name     = rule.value
      priority = 99

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          vendor_name = "AWS"
          name        = rule.value
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-${replace(rule.value, "AWSManagedRules", "")}"
        sampled_requests_enabled   = true
      }
    }
  }

  # AWS Managed Rule: Common Rule Set
  dynamic "rule" {
    for_each = var.enable_common_rule_set ? ["AWSManagedRulesCommonRuleSet"] : []

    content {
      name     = rule.value
      priority = 100

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          vendor_name = "AWS"
          name        = rule.value
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-${replace(rule.value, "AWSManagedRules", "")}"
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.name
    sampled_requests_enabled   = true
  }

  tags = {
    Name = "waf-${var.name}-${var.vpc_name}"
  }
}
