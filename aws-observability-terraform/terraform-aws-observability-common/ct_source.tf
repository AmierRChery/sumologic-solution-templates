#TODO
/*CloudTrailSource:
  Condition: install_cloudtrail_logs_source
  Type: Custom::AWSSource
  Properties:
    SourceType: AwsCloudTrailBucket
    ServiceToken: !GetAtt LambdaHelper.Arn
    Region: !Ref "AWS::Region"
    SourceName: !Ref CloudTrailLogsSourceName
    TargetBucketName: !If [create_cloudtrail_bucket, !Ref CommonS3Bucket, !Ref CloudTrailLogsBucketName]
    RemoveOnDeleteStack: !Ref RemoveSumoLogicResourcesOnDeleteStack
    SourceCategory: "aws/observability/cloudtrail/logs"
    CollectorId: !GetAtt SumoLogicHostedCollector.COLLECTOR_ID
    SumoAccessID: !Ref SumoLogicAccessID
    SumoAccessKey: !Ref SumoLogicAccessKey
    SumoDeployment: !Ref SumoLogicDeployment
    PathExpression: !Ref CloudTrailBucketPathExpression
    Fields:
      account: !Ref AccountAlias
    RoleArn: !GetAtt SumoLogicSourceRole.Arn*/

resource "aws_sns_topic" "cloudtrail_source" {
  for_each = range(local.manage_cloudtrail_sns_topic ? 1 : 0)

  name = "cloudtrail-sumo-sns-${var.account_alias}-" # TODO: verify
}

resource "aws_sns_topic_policy" "cloudtrail_source" {
  for_each = range(local.manage_cloudtrail_sns_topic ? 1 : 0)

  arn    = aws_sns_topic.cloudtrail_source[0].arn
  policy = templatefile("${path.module}/templates/sns/policy.tmpl", { bucket_arn = aws_s3_bucket.cloudtrail_logs.arn, sns_topic_arn = aws_sns_topic.cloudtrail_source[0].arn, aws_account = data.aws_caller_identity.current.id }) #TODO: s3 bucket for cloudtrail logs does not exist in cft
}

resource "aws_sns_topic_subscription" "cloudtrail_source" {
  for_each = range(var.manage_cloudtrail_logs_source ? 1 : 0)

  delivery_policy = jsonencode({
    "healthyRetryPolicy" = {
      "numRetries"         = 40,
      "minDelayTarget"     = 10,
      "maxDelayTarget"     = 300,
      "numMinDelayRetries" = 3,
      "numMaxDelayRetries" = 5,
      "numNoDelayRetries"  = 0,
      "backoffFunction"    = "exponential"
    }
  })
  endpoint  = CloudTrailSource.SUMO_ENDPOINT #TODO: sl resource attr
  protocol  = "https"
  topic_arn = var.manage_cloudtrail_bucket ? aws_sns_topic.common[0].arn : aws_sns_topic.cloudtrail_source[0].arn
}
