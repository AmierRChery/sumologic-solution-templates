#TODO
/*ALBSource:
  Condition: install_alb_logs_source
  Type: Custom::AWSSource
  Properties:
    SourceType: AwsElbBucket
    ServiceToken: !GetAtt LambdaHelper.Arn
    Region: !Ref "AWS::Region"
    SourceName: !Ref ALBLogsSourceName
    RemoveOnDeleteStack: !Ref RemoveSumoLogicResourcesOnDeleteStack
    SourceCategory: "aws/observability/alb/logs"
    CollectorId: !GetAtt SumoLogicHostedCollector.COLLECTOR_ID
    SumoAccessID: !Ref SumoLogicAccessID
    SumoAccessKey: !Ref SumoLogicAccessKey
    SumoDeployment: !Ref SumoLogicDeployment
    TargetBucketName: !If [create_alb_bucket, !Ref CommonS3Bucket, !Ref ALBS3LogsBucketName]
    PathExpression: !Ref ALBS3BucketPathExpression
    Fields:
      account: !Ref AccountAlias
      namespace: "aws/applicationelb"
      region: !Ref "AWS::Region"
    RoleArn: !GetAtt SumoLogicSourceRole.Arn*/

resource "aws_sns_topic" "alb_source" {
  for_each = range(local.manage_alb_sns_topic ? 1 : 0)

  name = "alb-sumo-sns-${var.account_alias}-" # TODO: verify
}

resource "aws_sns_topic_policy" "alb_source" {
  for_each = range(local.manage_alb_sns_topic ? 1 : 0)

  arn    = aws_sns_topic.alb_source[0].arn
  policy = templatefile("${path.module}/templates/sns/policy.tmpl", { bucket_arn = aws_s3_bucket.alb_logs.arn, sns_topic_arn = aws_sns_topic.alb_source[0].arn, aws_account = data.aws_caller_identity.current.id }) #TODO: s3 bucket for alb logs does not exist in cft
}

resource "aws_sns_topic_subscription" "alb_source" {
  for_each = range(var.manage_alb_logs_source ? 1 : 0)

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
  topic_arn = var.manage_alb_bucket ? aws_sns_topic.common[0].arn : aws_sns_topic.alb_source[0].arn
}
