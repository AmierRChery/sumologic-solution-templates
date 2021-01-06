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
  value       = aws_lambda_function.cloudwatch_logs_source_logs.arn
  description = "Cloudwatch logs source lambda arn."
}

output "enterprise_check" {
  value       = data.external.account_check.result.enterprise #TODO: update namespace
  description = "Check whether SumoLogic account is enterprise."
}

output "paid_check" {
  value       = data.external.account_check.result.paid #TODO: update namespace
  description = "Check whether SumoLogic account is paid."
}

output "cloudwatch_metrics_namespaces" {
  value       = var.cloudwatch_metrics_namespaces
  description = "CloudWatch Metrics Namespaces for Inventory Source."
}
