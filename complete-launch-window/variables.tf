variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "launch-window-workshop"
}

variable "done_email" {
  description = "Email address to subscribe to completion SNS topic (requires confirmation)"
  type        = string
  default     = "your@email.com"
}

variable "schedule_expression" {
  description = "EventBridge schedule expression (e.g., rate(5 minutes) or cron(...))"
  type        = string
  default     = "rate(5 minutes)"
}

variable "max_wind_kts" {
  description = "Maximum allowable wind speed (knots) for GO decision"
  type        = number
  default     = 20
}

variable "min_cloud_ceiling_ft" {
  description = "Minimum allowable cloud ceiling (feet) for GO decision"
  type        = number
  default     = 2500
}

variable "lightning_allowed" {
  description = "Whether lightning risk is allowed for GO decision"
  type        = bool
  default     = false
}

variable "range_allowed" {
  description = "Allowed range status for GO decision (GREEN only in this workshop)"
  type        = string
  default     = "GREEN"
}
