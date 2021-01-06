resource "sumologic_http_source" "cloudwatch_logs" {
  for_each = range(var.manage_cloudwatch_logs_source ? 1 : 0)

  category     = "aws/observability/cloudwatch/logs"
  collector_id = sumologic_collector[0].hosted.id
  name         = var.cloudwatch_logs_source_name

  filters { #TODO
    /*Fields:
        account: !Ref AccountAlias
        namespace: "aws/lambda"
        region: !Ref "AWS::Region"*/
    name        = "Test Exclude Debug"
    filter_type = "Exclude"
    regexp      = ".*DEBUG.*"
  }
}

resource "aws_iam_role" "cloudwatch_logs_source_lambda" {
  for_each = range(var.manage_cloudwatch_logs_source ? 1 : 0)

  name = "SumoCWLambdaExecutionRole" #TODO: verify
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

resource "aws_iam_role_policy" "cloudwatch_logs_source_lambda_sqs" {
  for_each = range(var.manage_cloudwatch_logs_source ? 1 : 0)

  name = "SQSCreateLogsRolePolicy" #TODO: verify
  role = aws_iam_role.cloudwatch_logs_source_lambda[0].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "sqs:DeleteMessage",
      "sqs:GetQueueUrl",
      "sqs:ListQueues",
      "sqs:ChangeMessageVisibility",
      "sqs:SendMessageBatch",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
      "sqs:GetQueueAttributes",
      "sqs:ListQueueTags",
      "sqs:ListDeadLetterSourceQueues",
      "sqs:DeleteMessageBatch",
      "sqs:PurgeQueue",
      "sqs:DeleteQueue",
      "sqs:CreateQueue",
      "sqs:ChangeMessageVisibilityBatch",
      "sqs:SetQueueAttributes"
    ],
    "Resource": "${aws_sqs_queue.cloudwatch_logs_source_deadletter[0].arn}"
  ]}
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch_logs_source_lambda_logs" {
  for_each = range(var.manage_cloudwatch_logs_source ? 1 : 0)

  name = "CloudWatchCreateLogsRolePolicy" #TODO: verify
  role = aws_iam_role.cloudwatch_logs_source_lambda[0].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ],
    "Resource": "log-group*" #TODO: check against account
  }]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch_logs_source_lambda_lambda" {
  for_each = range(var.manage_cloudwatch_logs_source ? 1 : 0)

  name = "InvokeLambdaRolePolicy"
  role = aws_iam_role.cloudwatch_logs_source_lambda[0].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "lambda:InvokeFunction"
    ],
    "Resource": "${aws_lambda_function.cloudwatch_logs_source_logs[0].arn}"
  }]
}
EOF
}

resource "aws_lambda_function" "cloudwatch_logs_source_logs" {
  for_each = range(var.manage_cloudwatch_logs_source ? 1 : 0)

  function_name = "SumoCWLogsLambda" #TODO: verify
  handler       = "cloudwatchlogs_lambda.handler"
  runtime       = "nodejs10.x"
  role          = aws_iam_role.cloudwatch_logs_source_lambda[0].arn
  s3_bucket     = "appdevzipfiles-${data.aws_region.current.id}"
  s3_key        = "cloudwatchlogs-with-dlq.zip"
  timeout       = 300

  dead_letter_config {
    target_arn = aws_sqs_queue.cloudwatch_logs_source_deadletter[0].arn
  }

  environment {
    variables = {
      "SUMO_ENDPOINT"     = sumologic_http_source.cloudwatch_logs[0].url,
      "LOG_FORMAT"        = var.log_format,
      "INCLUDE_LOG_INFO"  = var.include_log_group_info,
      "LOG_STREAM_PREFIX" = join(",", var.log_stream_prefix)
    }
  }
}

resource "aws_lambda_permission" "cloudwatch_logs_source_logs" {
  for_each = range(var.manage_cloudwatch_logs_source ? 1 : 0)

  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.cloudwatch_logs_source_logs[0].function_name
  principal      = "logs.${data.aws_region.current.id}.amazonaws.com"
  source_account = data.aws_caller_identity.current.id
}

resource "aws_lambda_function" "cloudwatch_logs_source_process_deadletter" {
  for_each = range(var.manage_cloudwatch_logs_source ? 1 : 0)

  function_name = "SumoCWProcessDLQLambda" #TODO: verify
  handler       = "DLQProcessor.handler"
  runtime       = "nodejs10.x"
  role          = aws_iam_role.cloudwatch_logs_source_lambda[0].arn
  s3_bucket     = "appdevzipfiles-${data.aws_region.current.id}"
  s3_key        = "cloudwatchlogs-with-dlq.zip"
  timeout       = 300

  dead_letter_config {
    target_arn = aws_sqs_queue.cloudwatch_logs_source_deadletter.arn
  }

  environment {
    variables = {
      "SUMO_ENDPOINT"     = sumologic_http_source.cloudwatch_logs[0].url,
      "LOG_FORMAT"        = var.log_format,
      "INCLUDE_LOG_INFO"  = var.include_log_group_info,
      "LOG_STREAM_PREFIX" = join(",", var.log_stream_prefix),
      "TASK_QUEUE_URL"    = aws_sqs_queue.cloudwatch_logs_source_deadletter[0].arn,
      "NUM_OF_WORKERS"    = var.workers
    }
  }
}

resource "aws_lambda_permission" "cloudwatch_logs_source_process_deadletter" {
  for_each = range(var.manage_cloudwatch_logs_source ? 1 : 0)

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudwatch_logs_source_process_deadletter[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = cw_process_dlq_schedule_rule.arn #TODO: update namespace
}

resource "aws_cloudwatch_event_rule" "cloudwatch_logs_source_process_deadletter" {
  for_each = range(var.manage_cloudwatch_logs_source ? 1 : 0)

  description         = "Events rule for Cron"
  name                = "SumoCWProcessDLQScheduleRule"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "yada" {
  for_each = range(var.manage_cloudwatch_logs_source ? 1 : 0)

  arn       = aws_lambda_function.cloudwatch_logs_source_process_deadletter.arn
  rule      = aws_cloudwatch_event_rule.cloudwatch_logs_source_process_deadletter[0].name
  target_id = "TargetFunctionV1"
}

resource "aws_sqs_queue" "cloudwatch_logs_source_deadletter" {
  for_each = range(var.manage_cloudwatch_logs_source ? 1 : 0)

  name = "SumoCWDeadLetterQueue" #TODO: verify
}

resource "aws_sns_topic" "cloudwatch_logs_source_email" {
  for_each = range(var.manage_cloudwatch_logs_source ? 1 : 0)

  name = "SumoCWEmailSNSTopic"
}

resource "aws_sns_topic_subscription" "cloudwatch_logs_source_email" {
  for_each = range(var.manage_cloudwatch_logs_source ? 1 : 0)

  endpoint  = var.email_id
  protocol  = "email" #TODO: will not work
  topic_arn = aws_sns_topic.cloudwatch_logs_source_email[0].arn
}

resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_logs_source" {
  for_each = range(var.manage_cloudwatch_logs_source ? 1 : 0)

  destination_arn = aws_lambda_function.cloudwatch_logs_source_logs[0].arn
  filter_pattern  = ""
  log_group_name  = aws_cloudwatch_log_group.cloudwatch_logs_source[0].name

  depends_on = [aws_lambda_permission.cloudwatch_logs_source_logs]
}

resource "aws_cloudwatch_log_group" "cloudwatch_logs_source" {
  for_each = range(var.manage_cloudwatch_logs_source ? 1 : 0)

  name              = "SumoCWLogGroup" #TODO: verify
  retention_in_days = 7
}

resource "aws_cloudwatch_metric_alarm" "cloudwatch_logs_source" {
  for_each = range(var.manage_cloudwatch_logs_source ? 1 : 0)

  alarm_actions       = [aws_sns_topic.cloudwatch_logs_source_email[0].arn]
  alarm_description   = "Notify via email if number of messages in DeadLetterQueue exceeds threshold"
  alarm_name          = "SumoCWSpilloverAlarm"
  comparison_operator = "GreaterThanThreshold"
  dimensions          = { "QueueName" = aws_sqs_queue.cloudwatch_logs_source_deadletter[0].name }
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 3600
  statistic           = "Sum"
  threshold           = 100000
}
