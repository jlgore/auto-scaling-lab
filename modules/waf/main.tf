# File: modules/waf/main.tf

resource "aws_wafv2_ip_set" "this" {
  for_each           = var.ip_sets
  name               = each.value.name
  description        = each.value.description
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = each.value.ip_addresses
}


resource "aws_wafv2_web_acl" "this" {
  name  = var.name
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  dynamic "rule" {
    for_each = var.rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }
      }

      statement {
        dynamic "ip_set_reference_statement" {
          for_each = rule.value.type == "ip_set" ? [1] : []
          content {
            arn = aws_wafv2_ip_set.this[rule.value.ip_set_key].arn
          }
        }
        dynamic "managed_rule_group_statement" {
          for_each = rule.value.type == "managed_rule_group" ? [1] : []
          content {
            name        = rule.value.managed_rule_name
            vendor_name = "AWS"
          }
        }
        dynamic "rate_based_statement" {
          for_each = rule.value.type == "rate_based" ? [1] : []
          content {
            limit              = rule.value.rate_limit
            aggregate_key_type = "IP"
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.name
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "this" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

