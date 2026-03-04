locals {
  name_prefix  = "yourname"
  project_name = "launch-window-by-${local.name_prefix}"
}

# -----------------------------
# Lambda 
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
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
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

  timeout     = 30
  memory_size = 128

  environment {
    variables = {
      ARTIFACT_BUCKET      = "TBD"           #aws_s3_bucket.artifacts.bucket
      DONE_TOPIC_ARN       = "TBD"           #aws_sns_topic.done.arn
      MAX_WIND_KTS         = tostring(20)    #tostring(var.max_wind_kts)
      MIN_CLOUD_CEILING_FT = tostring(2500)  #tostring(var.min_cloud_ceiling_ft)
      LIGHTNING_ALLOWED    = tostring(false) #tostring(var.false)
      RANGE_ALLOWED        = "GREEN"         #var.range_allowed
      ARTIFACT_PREFIX      = "launch-window"
    }
  }

  depends_on = [aws_iam_role_policy.lambda_inline]
}



