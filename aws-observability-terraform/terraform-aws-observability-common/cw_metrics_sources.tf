resource "aws_cloudformation_stack" "cloudwatch_metrics_sources" {
  for_each = var.manage_cloudwatch_metrics_source ? toset(var.cloudwatch_metrics_namespaces) : []

  name = "cloudwatch-metrics-sources-${each.value}"
  parameters = {
    "SumoLogicDeployment"                   = var.sumologic_environment
    "SumoLogicAccessID"                     = var.sumologic_access_id
    "SumoLogicAccessKey"                    = var.sumologic_access_key
    "RemoveSumoLogicResourcesOnDeleteStack" = var.remove_sumologic_resources_on_delete_stack
    "AccountAlias"                          = var.account_alias
    "SumoLogicCollectorId"                  = sumologic_collector.hosted.id
    "LambdaARN"                             = aws_lambda_function.helper.arn
    "SumoLogicSourceRole"                   = aws_iam_role.sumologic_source[0].arn
    "CloudWatchMetricsSourceName"           = var.cloudwatch_metrics_source_name
    "CreateFirstMetricsSource"              = "Yes",
    "FirstMetricsSourceNamespace"           = regex("AWS/(\\w+)", each.value)[0]
  }
  template_url = "https://${var.templates_bucket}-${data.aws_region.current.id}.s3.amazonaws.com/sumologic-aws-observability/apps/cloudwatchmetrics/cloudwatchmetrics.template.yaml"
}
