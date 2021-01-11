resource "sumologic_metadata_source" "this" {
  for_each = toset(var.manage_metadata_source ? ["this"] : [])

  category      = "aws/observability/ec2/metadata"
  collector_id  = sumologic_collector.hosted["this"].id
  content_type  = "AwsMetadata"
  name          = var.metadata_source_name
  paused        = false
  scan_interval = var.scan_interval

  authentication {
    type     = "AWSRoleBasedAuthentication"
    role_arn = aws_iam_role.sumologic_source["this"].id
  }

  path {
    type                = "AwsMetadataPath"
    limit_to_namespaces = ["AWS/EC2"]
  }
}

#TODO: sumoresource.py
data "external" "account_check" {
  program = ["echo", "-e", "{\"enterprise\":\"true\",\"paid\":\"true\"}"]

  query = {
    account_id = "id"
  }
}
# Error: command "echo" produced invalid JSON: json: cannot unmarshal bool into Go value of type string
