resource "aws_cloudformation_stack" "cloudwatch_logs_source" {
  for_each = range(var.manage_cloudwatch_logs_source ? 1 : 0)

  name = "cloudwatch-logs-source"
  parameters = {
    "SumoEndPointURL"     = sumologic_http_source.cloudwatch_logs.url
    "IncludeLogGroupInfo" = true
  }
  template_url = "https://s3.amazonaws.com/appdev-cloudformation-templates/DLQLambdaCloudFormation.json"
}

resource "sumologic_http_source" "cloudwatch_logs" {
  for_each = range(var.manage_cloudwatch_logs_source ? 1 : 0)

  category     = "aws/observability/cloudwatch/logs"
  collector_id = sumologic_collector[0].hosted.id
  name         = var.cloudwatch_logs_source_name

  filters { #TODO
    /*Fields:
        account: !Ref AccountAlias
        namespace: "aws/lambda"
        region: !Ref "AWS::Region"*/
    name        = "Test Exclude Debug"
    filter_type = "Exclude"
    regexp      = ".*DEBUG.*"
  }
}
