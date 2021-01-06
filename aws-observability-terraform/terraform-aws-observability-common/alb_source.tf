resource "sumologic_elb_source" "this" {
  for_each = range(var.manage_alb_logs_source ? 1 : 0)

  category      = "aws/observability/alb/logs"
  collector_id  = sumologic_collector[0].hosted.id
  content_type  = "AwsElbBucket"
  name          = var.alb_logs_source_name
  paused        = false
  scan_interval = var.scan_interval

  authentication {
    type     = "AWSRoleBasedAuthentication"
    role_arn = aws_iam_role.sumologic_source[0].id
  }

  path {
    type            = "S3BucketPathExpression"
    bucket_name     = var.manage_alb_bucket ? aws_s3_bucket.common[0].id : var.alb_logs_s3_bucket
    path_expression = var.alb_s3_bucket_path_expression
  }
}

resource "aws_sns_topic" "alb_source" {
  for_each = range(local.manage_alb_sns_topic ? 1 : 0)

  name = "alb-sumo-sns-${var.account_alias}-"
}

resource "aws_sns_topic_policy" "alb_source" {
  for_each = range(local.manage_alb_sns_topic ? 1 : 0)

  arn    = aws_sns_topic.alb_source[0].arn
  policy = templatefile("${path.module}/templates/sns/policy.tmpl", { bucket_arn = var.manage_alb_bucket ? aws_s3_bucket.common[0].arn : "arn:aws:s3:::${var.alb_logs_s3_bucket}", sns_topic_arn = aws_sns_topic.alb_source[0].arn, aws_account = data.aws_caller_identity.current.id })
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
  endpoint  = sumologic_elb_source.this.url
  protocol  = "https"
  topic_arn = var.manage_alb_bucket ? aws_sns_topic.common[0].arn : aws_sns_topic.alb_source[0].arn
}
