resource "aws_sns_topic" "common" {
  for_each = range(local.manage_target_s3_bucket ? 1 : 0)

  name = "sumo-sns-topic-${var.account_alias}-" #TODO: verify
}

resource "aws_sns_topic_policy" "common" {
  for_each = range(local.manage_target_s3_bucket ? 1 : 0)

  arn    = aws_sns_topic.common[0].arn
  policy = templatefile("${path.module}/templates/sns/policy.tmpl", { bucket_arn = aws_s3_bucket.common[0].arn, sns_topic_arn = aws_sns_topic.common[0].arn, aws_account = data.aws_caller_identity.current.id })
}

resource "aws_s3_bucket" "common" {
  for_each = range(local.manage_target_s3_bucket ? 1 : 0)

  bucket = "aws-observability-logs-" # TODO: verify
}

resource "aws_s3_bucket_notification" "common" {
  for_each = range(local.manage_target_s3_bucket ? 1 : 0)

  bucket = aws_s3_bucket.common[0].id

  topic {
    topic_arn = aws_sns_topic.common[0].arn
    events    = ["s3:ObjectCreated:Put"]
  }
}

resource "aws_s3_bucket_policy" "common" {
  for_each = range(local.manage_target_s3_bucket ? 1 : 0)

  bucket = aws_s3_bucket.common[0].id
  policy = templatefile("${path.module}/templates/s3/common.tmpl", { common_s3_bucket_arn = aws_s3_bucket.common[0].arn })
}

resource "aws_cloudtrail" "common" {
  for_each = range(var.manage_cloudtrail_bucket ? 1 : 0)

  name           = "Aws-Observability-${var.account_alias}"
  s3_bucket_name = aws_s3_bucket.common[0].id
}
