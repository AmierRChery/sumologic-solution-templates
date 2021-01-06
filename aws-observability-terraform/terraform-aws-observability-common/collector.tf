resource "sumologic_collector" "hosted" {
  for_each = range(var.manage_collector ? 1 : 0)

  name = var.collector_name
}

#TODO: check lambda code in zip file
/*CreateSumoLogicAWSExplorerView:
  Type: Custom::SumoLogicAWSExplorer
  Properties:
    HierarchyName: "AWS Observability"
    HierarchyLevel: {"entityType":"account","nextLevelsWithConditions":[],"nextLevel":{"entityType":"region","nextLevelsWithConditions":[],"nextLevel":{"entityType":"namespace","nextLevelsWithConditions":[{"condition":"AWS/ApplicationElb","level":{"entityType":"loadbalancer","nextLevelsWithConditions":[]}},{"condition":"AWS/ApiGateway","level":{"entityType":"apiname","nextLevelsWithConditions":[]}},{"condition":"AWS/DynamoDB","level":{"entityType":"tablename","nextLevelsWithConditions":[]}},{"condition":"AWS/EC2","level":{"entityType":"instanceid","nextLevelsWithConditions":[]}},{"condition":"AWS/RDS","level":{"entityType":"dbidentifier","nextLevelsWithConditions":[]}},{"condition":"AWS/Lambda","level":{"entityType":"functionname","nextLevelsWithConditions":[]}}]}}}*/

resource "aws_iam_role" "sumologic_source" {
  for_each = range(local.manage_sumologic_source_role ? 1 : 0)

  name = "sumologic-source"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "arn:aws:iam::926226587429:root"
      },
      "Effect": "Allow",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "${var.sumologic_environment}:${var.sumologic_organization_id}"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "sumologic_source" {
  name = "SumoLogicAwsSourcesPolicies"
  role = aws_iam_role.sumologic_source[0].id

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Action":[
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:ListBucketVersions",
        "s3:ListBucket",
        "tag:GetResources",
        "cloudwatch:ListMetrics",
        "cloudwatch:GetMetricStatistics"
      ],
      "Resource":"*"
    }
  ]
}
EOF
}
