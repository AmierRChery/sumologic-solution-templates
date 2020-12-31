resource "aws_cloudformation_stack" "cloudwatch_logs_source" {
  for_each = range(var.manage_cloudwatch_logs_source ? 1 : 0)

  name = "cloudwatch-logs-source"
  parameters = {
    "SumoEndPointURL"     = CloudWatchHTTPSource.SUMO_ENDPOINT, #TODO: sl resource attr
    "IncludeLogGroupInfo" = true
  }
  template_url = "https://s3.amazonaws.com/appdev-cloudformation-templates/DLQLambdaCloudFormation.json"
}

#TODO
/*CloudWatchHTTPSource:
  Condition: install_cloudwatch_logs_source
  Type: Custom::HTTPSource
  Properties:
    ServiceToken: !GetAtt LambdaHelper.Arn
    Region: !Ref "AWS::Region"
    SourceName: !Ref CloudWatchLogsSourceName
    RemoveOnDeleteStack: !Ref RemoveSumoLogicResourcesOnDeleteStack
    SourceCategory: "aws/observability/cloudwatch/logs"
    CollectorId: !GetAtt SumoLogicHostedCollector.COLLECTOR_ID
    SumoAccessID: !Ref SumoLogicAccessID
    SumoAccessKey: !Ref SumoLogicAccessKey
    SumoDeployment: !Ref SumoLogicDeployment
    Fields:
      account: !Ref AccountAlias
      namespace: "aws/lambda"
      region: !Ref "AWS::Region"*/
