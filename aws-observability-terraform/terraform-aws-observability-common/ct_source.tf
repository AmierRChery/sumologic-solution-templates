resource "sumologic_cloudtrail_source" "this" {
  for_each = range(var.manage_cloudtrail_logs_source ? 1 : 0)

  category      = "aws/observability/cloudtrail/logs"
  collector_id  = sumologic_collector[0].hosted.id
  content_type  = "AwsCloudTrailBucket"
  name          = var.cloudtrail_logs_source_name
  paused        = false
  scan_interval = var.scan_interval

  authentication {
    type     = "AWSRoleBasedAuthentication"
    role_arn = aws_iam_role.sumologic_source[0].id
  }

  path {
    type            = "S3BucketPathExpression"
    bucket_name     = var.manage_cloudtrail_bucket ? aws_s3_bucket.common[0].arn : aws_s3_bucket.cloudtrail_logs[0].arn #TODO: s3 bucket for cloudtrail logs does not exist in cft
    path_expression = var.cloudtrail_s3_bucket_path_expression
  }
}

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
  endpoint  = sumologic_cloudtrail_source.this.url
  protocol  = "https"
  topic_arn = var.manage_cloudtrail_bucket ? aws_sns_topic.common[0].arn : aws_sns_topic.cloudtrail_source[0].arn
}
