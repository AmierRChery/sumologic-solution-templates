resource "sumologic_cloudtrail_source" "this" {
  for_each = toset(var.manage_cloudtrail_logs_source ? ["this"] : [])

  category      = "aws/observability/cloudtrail/logs"
  collector_id  = sumologic_collector.hosted["this"].id
  content_type  = "AwsCloudTrailBucket"
  name          = var.cloudtrail_logs_source_name
  paused        = false
  scan_interval = var.scan_interval

  authentication {
    type     = "AWSRoleBasedAuthentication"
    role_arn = aws_iam_role.sumologic_source["this"].id
  }

  path {
    type            = "S3BucketPathExpression"
    bucket_name     = var.manage_cloudtrail_bucket ? aws_s3_bucket.common["this"].id : var.cloudtrail_logs_s3_bucket
    path_expression = var.cloudtrail_s3_bucket_path_expression
  }
}

resource "aws_sns_topic" "cloudtrail_source" {
  for_each = toset(local.manage_cloudtrail_sns_topic ? ["this"] : [])

  name = "cloudtrail-sumo-sns-${var.account_alias}"
}

resource "aws_sns_topic_policy" "cloudtrail_source" {
  for_each = toset(local.manage_cloudtrail_sns_topic ? ["this"] : [])

  arn    = aws_sns_topic.cloudtrail_source["this"].arn
  policy = templatefile("${path.module}/templates/sns/policy.tmpl", { bucket_arn = var.manage_cloudtrail_bucket ? aws_s3_bucket.common["this"].arn : "arn:aws:s3:::${var.cloudtrail_logs_s3_bucket}", sns_topic_arn = aws_sns_topic.cloudtrail_source["this"].arn, aws_account = data.aws_caller_identity.current.id })
}

resource "aws_sns_topic_subscription" "cloudtrail_source" {
  for_each = toset(var.manage_cloudtrail_logs_source ? ["this"] : [])

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
  endpoint  = sumologic_cloudtrail_source.this["this"].url
  protocol  = "https"
  topic_arn = var.manage_cloudtrail_bucket ? aws_sns_topic.common["this"].arn : aws_sns_topic.cloudtrail_source["this"].arn
}
