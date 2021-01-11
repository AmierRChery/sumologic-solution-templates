resource "sumologic_cloudwatch_source" "cloudwatch_metrics_sources" {
  for_each = var.manage_cloudwatch_metrics_source ? toset(var.cloudwatch_metrics_namespaces) : []

  category      = "aws/observability/cloudwatch/metrics"
  collector_id  = sumologic_collector.hosted["this"].id
  content_type  = "AwsCloudWatch"
  name          = "${var.cloudwatch_metrics_source_name}-${each.value}"
  paused        = false
  scan_interval = local.namespace_scan_interval[regex("^AWS/(\\w+)$", each.value)[0]]

  authentication {
    type     = "AWSRoleBasedAuthentication"
    role_arn = aws_iam_role.sumologic_source["this"].arn
  }

  path {
    type                = "CloudWatchPath"
    limit_to_regions    = [data.aws_region.current.id]
    limit_to_namespaces = var.cloudwatch_metrics_namespaces

    tag_filters {
      type      = "TagFilters"
      namespace = each.value
      tags      = ["account=${var.account_alias}"]
    }
  }
}
