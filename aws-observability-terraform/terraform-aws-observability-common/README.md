# terraform-aws-observability-common

Terraform module to setup Sumo Logic Sources and supporting AWS Resources for CloudTrail, ALB, Lambda CloudWatch Logs, and CloudWatch Metrics.

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.13 |
| aws | ~> 3.0 |
| external | ~> 2.0 |
| sumologic | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.0 |
| external | ~> 2.0 |
| sumologic | ~> 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account\_alias | Provide an Alias for the AWS account for identification in Sumo Logic Explorer View, metrics, and logs. Please do not include special characters. | `string` | n/a | yes |
| alb\_logs\_source\_name | Name for the ALB logs source. | `string` | `""` | no |
| alb\_s3\_bucket | The preconfigured S3 bucket for ALB logs if the bucket is not managed in this module config. | `string` | `""` | no |
| alb\_s3\_bucket\_path\_expression | Path expression to match one or more S3 objects; e.g. 'ABC\*.log' or 'ABC.log'. | `string` | `"*"` | no |
| cloudtrail\_logs\_s3\_bucket | The preconfigured S3 bucket for Cloudtrail logs if the bucket is not managed in this module config. | `string` | `""` | no |
| cloudtrail\_logs\_source\_name | Name for the Cloudtrail logs source. | `string` | `""` | no |
| cloudtrail\_s3\_bucket\_path\_expression | Path expression to match one or more S3 objects; e.g. 'ABC\*.log' or 'ABC.log'. | `string` | `"*"` | no |
| cloudwatch\_logs\_source\_name | Name for the Cloudwatch logs source. | `string` | `""` | no |
| cloudwatch\_metrics\_namespaces | List of the Cloudwatch metrics namespaces. | `list(string)` | <pre>[<br>  "AWS/ApplicationELB, AWS/ApiGateway, AWS/DynamoDB, AWS/Lambda, AWS/RDS, AWS/ECS, AWS/ElastiCache, AWS/ELB, AWS/NetworkELB"<br>]</pre> | no |
| cloudwatch\_metrics\_source\_name | Cloudwatch metrics source name to override the default. If unspecified, the default name will be used. | `string` | `""` | no |
| collector\_name | Name of the SumoLogic collector. | `string` | `""` | no |
| manage\_alb\_logs\_source | Whether to manage the Sumo Logic ALB Log Source with provided bucket Name. | `bool` | `false` | no |
| manage\_alb\_s3\_bucket | Whether to manage the S3 bucket for ALB. Do not enable if you preconfigured a S3 bucket for this purpose. | `bool` | `false` | no |
| manage\_cloudtrail\_bucket | Whether to manage the Cloudtrail S3 bucket. Do not enable if you preconfigured a S3 bucket for Cloudtrail. | `bool` | `false` | no |
| manage\_cloudtrail\_logs\_source | Whether to manage the Sumo Logic Cloud Trail Log Source with provided bucket Name. | `bool` | `false` | no |
| manage\_cloudwatch\_logs\_source | Whether to manage the Sumo Logic Cloud Watch Log Source. | `bool` | `false` | no |
| manage\_cloudwatch\_metrics\_source | Whether to manage a Sumo Logic CloudWatch Metrics Source which collects Metrics for multiple Namespaces from the region selected. Do not enable if you preconfigured a CloudWatch Metrics Source to collect ALB metrics. | `string` | `false` | no |
| manage\_metadata\_source | Whether to manage the SumoLogic MetaData Source. A common metadata source will be managed with the region selected. Do not enable if you preconfigured a MetaData Source. | `bool` | `false` | no |
| metadata\_source\_name | Metadata source name to override the default. If unspecified, the default name will be used. | `string` | `""` | no |
| remove\_sumologic\_resources\_on\_delete\_stack | Whether to delete collectors, sources, and apps when the stack is deleted. Deletes the resources created by the stack. Deletion of updated resources will be skipped. | `bool` | `true` | no |
| scan\_interval | The scan interval to fetch metrics into Sumo Logic. | `number` | `300000` | no |
| sumologic\_access\_id | SumoLogic access id for API invocations. | `string` | n/a | yes |
| sumologic\_access\_key | SumoLogic access key for API invocations. | `string` | n/a | yes |
| sumologic\_environment | SumoLogic environment abbreviation. | `string` | n/a | yes |
| sumologic\_organization\_id | Appears on the Account Overview page that displays information about your Sumo Logic organization. Used for IAM Role in Sumo Logic AWS Sources. | `string` | n/a | yes |
| templates\_bucket | Name of the S3 bucket containing nested CFTs. | `string` | `"appdevzipfiles-us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudwatch\_logs\_source\_lambda\_arn | Cloudwatch logs source lambda arn. |
| cloudwatch\_metrics\_namespaces | CloudWatch Metrics Namespaces for Inventory Source. |
| common\_bucket | Exported attributes for the common bucket. |
| enterprise\_check | Check whether SumoLogic account is enterprise. |
| lambda\_helper\_arn | Sumo Logic Lambda Helper ARN |
| lambda\_role\_arn | Sumo Logic Lambda Helper Role ARN |
| paid\_check | Check whether SumoLogic account is paid. |
