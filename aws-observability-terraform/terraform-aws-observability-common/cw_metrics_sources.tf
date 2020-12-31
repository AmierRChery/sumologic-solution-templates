#TODO: ask if still necessary given below code, and also lambda code seems to add "AWS/AutoScaling" but not used in cft for metrics sources
resource "aws_lambda_function" "cloudwatch_metrics_sources" {
  filename         = "${path.module}/files/lambda/cloudwatch_metrics_sources.zip"
  function_name    = "LambdaToDecideCWMetricsSources"
  handler          = "index.lambda_handler"
  role             = aws_iam_role.lambda.arn
  runtime          = "python3.7"
  source_code_hash = filebase64sha256("${path.module}/files/lambda/cloudwatch_metrics_sources.zip")
  timeout          = 60

  environment {
    variables = {
      "CloudWatchMetricsNameSpaces" = join(",", var.cloudwatch_metrics_namespaces)
      "ScanInterval"                = var.scan_interval
    }
  }
}

resource "aws_cloudformation_stack" "cloudwatch_metrics_sources" {
  for_each = var.manage_cloudwatch_metrics_source ? toset(var.cloudwatch_metrics_namespaces) : []

  name = "cloudwatch-metrics-sources-${each.value}"
  parameters = {
    "SumoLogicDeployment"                   = var.sumologic_environment
    "SumoLogicAccessID"                     = var.sumologic_access_id
    "SumoLogicAccessKey"                    = var.sumologic_access_key
    "RemoveSumoLogicResourcesOnDeleteStack" = var.remove_sumologic_resources_on_delete_stack
    "AccountAlias"                          = var.account_alias
    "SumoLogicCollectorId"                  = SumoLogicHostedCollector.COLLECTOR_ID #TODO: sl resource attr
    "LambdaARN"                             = aws_lambda_function.helper.arn
    "SumoLogicSourceRole"                   = aws_iam_role.sumologic_source[0].arn
    "CloudWatchMetricsSourceName"           = var.cloudwatch_metrics_source_name
    "CreateFirstMetricsSource"              = "Yes",
    "FirstMetricsSourceNamespace"           = regex("AWS/(\\w+)", each.value)[0]
  }
  template_url = "https://${var.templates_bucket}.s3.amazonaws.com/sumologic-aws-observability/apps/cloudwatchmetrics/cloudwatchmetrics.template.yaml"
}
