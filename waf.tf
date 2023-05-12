module "waf_regional" {

  source      = "umotif-public/waf-webaclv2/aws"
  name_prefix = "${var.SERVICE}-${var.BUILD_STAGE}"
  description = "${var.SERVICE}-${var.BUILD_STAGE}"
  scope       = "REGIONAL"

  allow_default_action   = true
  create_alb_association = false

  visibility_config = {
    cloudwatch_metrics_enabled = false
    metric_name                = "${var.SERVICE}-${var.BUILD_STAGE}"
    sampled_requests_enabled   = true
  }

  rules = [
    {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 1

      override_action = "none"

      managed_rule_group_statement = {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        excluded_rule = [
          "SizeRestrictions_QUERYSTRING",
          "NoUserAgent_HEADER"
        ]
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.SERVICE}-${var.BUILD_STAGE}-AWSManagedRulesCommonRuleSet"
        sampled_requests_enabled   = true
      }
    },
    {
      name     = "AWSManagedRulesKnownBadInputsRuleSet"
      priority = 2

      override_action = "count"


      managed_rule_group_statement = {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.SERVICE}-${var.BUILD_STAGE}-AWSManagedRulesKnownBadInputsRuleSet"
        sampled_requests_enabled   = true
      }
    },
    {
      name     = "AWSManagedRulesSQLiRuleSet"
      priority = 3

      override_action = "count"


      managed_rule_group_statement = {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.SERVICE}-${var.BUILD_STAGE}-AWSManagedRulesSQLiRuleSet"
        sampled_requests_enabled   = true
      }
    },
    {
      name     = "AWSManagedRulesAmazonIpReputationList"
      priority = 4

      override_action = "count"


      managed_rule_group_statement = {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.SERVICE}-${var.BUILD_STAGE}-AWSManagedRulesAmazonIpReputationList"
        sampled_requests_enabled   = true
      }
    },
    {
      name     = "RateLimitByIp"
      priority = 5

      action = "count"


      rate_based_statement = {
        limit              = 10000
        aggregate_key_type = "IP"
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.SERVICE}-${var.BUILD_STAGE}-RateLimitByIp"
        sampled_requests_enabled   = true
      }
    },
  ]

  tags = local.common_tags
}
