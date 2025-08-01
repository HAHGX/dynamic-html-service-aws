resource "aws_wafv2_web_acl" "html_api_acl" {
  name        = "HTMLAPIWebACL-${terraform.workspace}"
  description = "Web ACL for HTML API in ${terraform.workspace} environment"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "HTMLAPIWebACL"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "RateLimitRule"
    priority = 1

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    action {
      block {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }
  }
}

resource "aws_wafv2_web_acl_association" "html_api_acl_association" {
  resource_arn = aws_apigatewayv2_api.html_api.execution_arn
  web_acl_arn  = aws_wafv2_web_acl.html_api_acl.arn
}

