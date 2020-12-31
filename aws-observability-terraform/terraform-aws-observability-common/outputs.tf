output "lambda_helper_arn" {
  value       = aws_lambda_function.helper.arn
  description = "Sumo Logic Lambda Helper ARN"
}

output "lambda_role_arn" {
  value       = aws_iam_role.lambda.arn
  description = "Sumo Logic Lambda Helper Role ARN"
}

output "common_bucket" {
  value       = local.manage_target_s3_bucket ? aws_s3_bucket.common : {}
  description = "Exported attributes for the common bucket."
}

output "cloudwatch_logs_source_lambda_arn" {
  value       = aws_cloudformation_stack.cloudwatch_logs_source.outputs.SumoCWLogsLambdaArn
  description = "Cloudwatch logs source lambda arn."
}

#TODO
/*EnterpriseCheck:
  Description: "Check If Account is Enterprise or Not"
  Value: !GetAtt AccountCheck.is_enterprise
PaidAccountCheck:
  Description: "Check If Account is Paid or Not"
  Value: !GetAtt AccountCheck.is_paid*/

output "cloudwatch_metrics_namespaces" {
  value       = var.cloudwatch_metrics_namespaces
  description = "CloudWatch Metrics Namespaces for Inventory Source."
}
