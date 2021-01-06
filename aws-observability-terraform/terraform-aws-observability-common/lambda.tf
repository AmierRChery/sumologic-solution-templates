resource "aws_iam_role" "lambda" {
  name = "lambda"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda" {
  name = "AwsObservabilityLambdaExecutePolicies"
  role = aws_iam_role.lambda.id

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Action":[
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "s3:GetBucketPolicy",
        "s3:PutBucketPolicy"
      ],
      "Resource":"*"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "helper" {
  function_name = "LambdaHelper"
  handler       = "main.handler"
  runtime       = "python3.7"
  role          = aws_iam_role.lambda.arn
  s3_bucket     = "${var.templates_bucket}-${data.aws_region.current.id}"
  s3_key        = "sumologic-aws-observability/apps/SumoLogicAWSObservabilityHelper/SumoLogicAWSObservabilityHelperv2.0.10.zip"
  timeout       = 900
}
