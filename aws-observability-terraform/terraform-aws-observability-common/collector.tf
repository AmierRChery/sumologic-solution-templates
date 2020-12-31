#TODO
/*CreateSumoLogicAWSExplorerView:
  Type: Custom::SumoLogicAWSExplorer
  Properties:
    ServiceToken: !GetAtt LambdaHelper.Arn
    RemoveOnDeleteStack: false
    HierarchyName: "AWS Observability"
    HierarchyLevel: {"entityType":"account","nextLevelsWithConditions":[],"nextLevel":{"entityType":"region","nextLevelsWithConditions":[],"nextLevel":{"entityType":"namespace","nextLevelsWithConditions":[{"condition":"AWS/ApplicationElb","level":{"entityType":"loadbalancer","nextLevelsWithConditions":[]}},{"condition":"AWS/ApiGateway","level":{"entityType":"apiname","nextLevelsWithConditions":[]}},{"condition":"AWS/DynamoDB","level":{"entityType":"tablename","nextLevelsWithConditions":[]}},{"condition":"AWS/EC2","level":{"entityType":"instanceid","nextLevelsWithConditions":[]}},{"condition":"AWS/RDS","level":{"entityType":"dbidentifier","nextLevelsWithConditions":[]}},{"condition":"AWS/Lambda","level":{"entityType":"functionname","nextLevelsWithConditions":[]}}]}}}
    SumoAccessID: !Ref SumoLogicAccessID
    SumoAccessKey: !Ref SumoLogicAccessKey
    SumoDeployment: !Ref SumoLogicDeployment

    SumoLogicHostedCollector:
      Type: Custom::Collector
      Condition: install_collector
      Properties:
        ServiceToken: !GetAtt LambdaHelper.Arn
        Region: !Ref "AWS::Region"
        CollectorType: Hosted
        RemoveOnDeleteStack: !Ref RemoveSumoLogicResourcesOnDeleteStack
        CollectorName: !Ref CollectorName
        SumoAccessID: !Ref SumoLogicAccessID
        SumoAccessKey: !Ref SumoLogicAccessKey
        SumoDeployment: !Ref SumoLogicDeployment*/

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
