resource "sumologic_metadata_source" "this" {
  for_each = range(local.manage_metadata_source ? 1 : 0)

  category      = "aws/observability/ec2/metadata"
  collector_id  = sumologic_collector[0].hosted.id
  content_type  = "AwsMetadata"
  name          = var.metadata_source_name
  paused        = false
  scan_interval = var.scan_interval

  authentication {
    type     = "AWSRoleBasedAuthentication"
    role_arn = aws_iam_role.sumologic_source[0].id
  }

  path {
    type                = "AwsMetadataPath"
    limit_to_namespaces = ["AWS/EC2"]
  }
}

#TODO: knowledge transfer
data "external" "account_check" {
  program = ["echo", "account_check"]

  query = {
    account_id = "id"
  }
}
