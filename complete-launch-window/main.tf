locals {
  project_name = "launch-window-by-telma"
}

# -----------------------------
# S3 bucket for audit artifacts
# -----------------------------
resource "aws_s3_bucket" "artifacts" {
  bucket = lower("${local.project_name}-artifacts")
  
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

# -----------------------------
# SNS Topics
# -----------------------------
resource "aws_sns_topic" "ingest" {
  name = "${local.project_name}-ingest"
}

resource "aws_sns_topic" "done" {
  name = "${local.project_name}-done"
}

resource "aws_sns_topic_subscription" "done_email" {
  topic_arn = aws_sns_topic.done.arn
  protocol  = "email"
  endpoint  = "tfrege@gmail.com"
}

# -----------------------------
# SQS Queue (subscribed to ingest topic)
# -----------------------------
resource "aws_sqs_queue" "launch_queue" {
  name                       = "${local.project_name}-queue"
  visibility_timeout_seconds = 120
  message_retention_seconds  = 86400
}

# Allow SNS ingest topic to send messages to the SQS queue
data "aws_iam_policy_document" "sqs_queue_policy" {
  statement {
    sid     = "AllowSNSToSendMessage"
    effect  = "Allow"
    actions = ["sqs:SendMessage"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    resources = [aws_sqs_queue.launch_queue.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.ingest.arn]
    }
  }
}

resource "aws_sqs_queue_policy" "launch_queue" {
  queue_url = aws_sqs_queue.launch_queue.id
  policy    = data.aws_iam_policy_document.sqs_queue_policy.json
}

# Subscribe SQS queue to ingest SNS topic
resource "aws_sns_topic_subscription" "ingest_sqs" {
  topic_arn = aws_sns_topic.ingest.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.launch_queue.arn
  # raw_message_delivery keeps the SNS envelope; it's a good teaching moment.
  raw_message_delivery = false
  depends_on = [aws_sqs_queue_policy.launch_queue]
}

# -----------------------------
# Allow EventBridge to publish to ingest SNS topic
# -----------------------------
data "aws_iam_policy_document" "sns_ingest_policy" {
  statement {
    sid     = "AllowEventBridgePublish"
    effect  = "Allow"
    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.ingest.arn]
  }
}

resource "aws_sns_topic_policy" "ingest" {
  arn    = aws_sns_topic.ingest.arn
  policy = data.aws_iam_policy_document.sns_ingest_policy.json
}

# -----------------------------
# EventBridge schedule rule -> SNS ingest
# -----------------------------
resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${local.project_name}-schedule"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "to_sns" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "snsIngest"
  arn       = aws_sns_topic.ingest.arn

  input = jsonencode({
    mission      = var.mission
    launch_site  = var.launch_site
    vehicle      = var.vehicle
    # Keep window fields; Lambda will also add computed fields.
    window_start_utc = ""
    window_end_utc   = ""
  })
  depends_on = [aws_sns_topic_policy.ingest]
}

# -----------------------------
# Lambda (triggered by SQS)
# -----------------------------
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/.build/lambda.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "${local.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [aws_sqs_queue.launch_queue.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.artifacts.arn}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [aws_sns_topic.done.arn]
  }
}

resource "aws_iam_role_policy" "lambda_inline" {
  name   = "${local.project_name}-lambda-policy"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_lambda_function" "launch_eval" {
  function_name = "${local.project_name}-launch-eval"
  role          = aws_iam_role.lambda_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout = 30
  memory_size = 128

  environment {
    variables = {
      ARTIFACT_BUCKET          = aws_s3_bucket.artifacts.bucket
      DONE_TOPIC_ARN           = aws_sns_topic.done.arn
      MAX_WIND_KTS             = tostring(var.max_wind_kts)
      MIN_CLOUD_CEILING_FT     = tostring(var.min_cloud_ceiling_ft)
      LIGHTNING_ALLOWED        = tostring(var.lightning_allowed)
      RANGE_ALLOWED            = var.range_allowed
      ARTIFACT_PREFIX          = "launch-window"
    }
  }

  depends_on = [aws_iam_role_policy.lambda_inline]
}

# Map SQS -> Lambda trigger
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.launch_queue.arn
  function_name    = aws_lambda_function.launch_eval.arn
  batch_size       = 5
  enabled          = true
}
