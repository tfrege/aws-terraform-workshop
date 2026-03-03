output "artifact_bucket" {
  description = "S3 bucket where launch window reports are stored"
  value       = aws_s3_bucket.artifacts.bucket
}

output "sns_ingest_topic_arn" {
  description = "SNS ingest topic ARN (EventBridge target)"
  value       = aws_sns_topic.ingest.arn
}

output "sns_done_topic_arn" {
  description = "SNS completion topic ARN (Lambda publishes here)"
  value       = aws_sns_topic.done.arn
}

output "sqs_queue_url" {
  description = "SQS queue URL receiving ingest events"
  value       = aws_sqs_queue.launch_queue.id
}

output "eventbridge_rule_name" {
  description = "EventBridge schedule rule name"
  value       = aws_cloudwatch_event_rule.schedule.name
}
