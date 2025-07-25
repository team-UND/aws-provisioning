locals {
  has_exceptions          = length(var.common_rule_set_exceptions) > 0
  has_multiple_exceptions = length(var.common_rule_set_exceptions) > 1
}

resource "aws_wafv2_web_acl" "default" {
  name  = "${var.name}-${var.vpc_name}"
  scope = var.scope

  default_action {
    allow {}
  }

  # IP blocking rules
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

  # Rate limiting rule
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

  # AWS IP Reputation List
  dynamic "rule" {
    for_each = var.enable_ip_reputation_rule ? ["AWSManagedRulesAmazonIpReputationList"] : []
    content {
      name     = rule.value
      priority = 98
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

  # Common Rule Set - Exception Paths Only
  dynamic "rule" {
    for_each = var.enable_common_rule_set && local.has_exceptions ? ["CommonRuleSet-Exceptions"] : []
    content {
      name     = rule.value
      priority = 99
      override_action {
        none {}
      }
      statement {
        managed_rule_group_statement {
          vendor_name = "AWS"
          name        = "AWSManagedRulesCommonRuleSet"

          # Rule overrides for exceptions
          dynamic "rule_action_override" {
            for_each = var.common_rule_set_exceptions
            content {
              name = rule_action_override.value.rule_name
              action_to_use {
                allow {}
              }
            }
          }

          # Scope to exception paths only
          scope_down_statement {
            # Multiple exceptions: use OR statement
            dynamic "or_statement" {
              for_each = local.has_multiple_exceptions ? [1] : []
              content {
                dynamic "statement" {
                  for_each = var.common_rule_set_exceptions
                  content {
                    byte_match_statement {
                      search_string = statement.value.path
                      field_to_match {
                        uri_path {}
                      }
                      text_transformation {
                        priority = 0
                        type     = "LOWERCASE"
                      }
                      positional_constraint = statement.value.match_type
                    }
                  }
                }
              }
            }

            # Single exception: use direct byte match
            dynamic "byte_match_statement" {
              for_each = local.has_exceptions && !local.has_multiple_exceptions ? var.common_rule_set_exceptions : []
              content {
                search_string = byte_match_statement.value.path
                field_to_match {
                  uri_path {}
                }
                text_transformation {
                  priority = 0
                  type     = "LOWERCASE"
                }
                positional_constraint = byte_match_statement.value.match_type
              }
            }
          }
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-CommonRuleSet-Exceptions"
        sampled_requests_enabled   = true
      }
    }
  }

  # Common Rule Set - All Other Paths
  dynamic "rule" {
    for_each = var.enable_common_rule_set ? ["CommonRuleSet-Normal"] : []
    content {
      name     = rule.value
      priority = 100
      override_action {
        none {}
      }
      statement {
        managed_rule_group_statement {
          vendor_name = "AWS"
          name        = "AWSManagedRulesCommonRuleSet"

          # Exclude exception paths if they exist
          dynamic "scope_down_statement" {
            for_each = local.has_exceptions ? [1] : []
            content {
              not_statement {
                statement {
                  # Multiple exceptions: use OR statement
                  dynamic "or_statement" {
                    for_each = local.has_multiple_exceptions ? [1] : []
                    content {
                      dynamic "statement" {
                        for_each = var.common_rule_set_exceptions
                        content {
                          byte_match_statement {
                            search_string = statement.value.path
                            field_to_match {
                              uri_path {}
                            }
                            text_transformation {
                              priority = 0
                              type     = "LOWERCASE"
                            }
                            positional_constraint = statement.value.match_type
                          }
                        }
                      }
                    }
                  }

                  # Single exception: use direct byte match
                  dynamic "byte_match_statement" {
                    for_each = local.has_exceptions && !local.has_multiple_exceptions ? var.common_rule_set_exceptions : []
                    content {
                      search_string = byte_match_statement.value.path
                      field_to_match {
                        uri_path {}
                      }
                      text_transformation {
                        priority = 0
                        type     = "LOWERCASE"
                      }
                      positional_constraint = byte_match_statement.value.match_type
                    }
                  }
                }
              }
            }
          }
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-CommonRuleSet-Normal"
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
