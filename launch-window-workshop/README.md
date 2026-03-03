# Launch Window Notification Workshop (Terraform + AWS)

This repo is a complete 2-hour workshop where participants build a small, event-driven AWS solution **entirely with Terraform**.

## What you will build

**EventBridge (schedule) → SNS (ingest) → (email + SQS) → SQS → Lambda (Python) → SNS (done email) + S3 (audit report)**

### Behavior
- EventBridge runs on a schedule and publishes a small JSON payload to an SNS **ingest** topic.
- SNS fans out to:
  - an email subscriber (to prove scheduling + fan-out works)
  - an SQS queue (for processing)
- Lambda is triggered from SQS, simulates launch constraints (wind/clouds/lightning/range), decides **GO / NO-GO**, stores a JSON report in S3, and publishes a completion message to an SNS **done** topic that emails you the outcome.

---

## Prerequisites (before the workshop)

1. **AWS Account access**
   - Permissions to create: S3, SNS, SQS, Lambda, EventBridge, IAM.
2. **Tools installed**
   - Terraform `>= 1.5`
   - AWS CLI configured (`aws configure`) or SSO session
3. **Two email addresses** (can be the same)
   - One to subscribe to the ingest topic
   - One to subscribe to the completion topic  
   **SNS email subscriptions require confirmation** (you must click the link in your inbox).

---

## Repo structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── provider.tf
└── lambda
    └── handler.py
```

---

## Workshop steps (end-to-end)

> Estimated total time: ~2 hours

### 0) Clone / unzip repo

If you received this as a zip, unzip and `cd` into the folder.

### 1) Set your Terraform variables

Create a `terraform.tfvars` file:

```hcl
aws_region   = "us-east-1"
project_name = "launch-window-demo"

ingest_email = "YOUR_EMAIL@example.com"
done_email   = "YOUR_EMAIL@example.com"

# Fast feedback for workshop:
schedule_expression = "rate(2 minutes)"

mission     = "DEMO-1"
launch_site = "KSC"
vehicle     = "LV-A"

max_wind_kts         = 20
min_cloud_ceiling_ft = 2500
lightning_allowed    = false
range_allowed        = "GREEN"
```

### 2) Initialize Terraform

```bash
terraform init
```

### 3) Review the plan

```bash
terraform plan
```

### 4) Deploy

```bash
terraform apply
```

When it finishes, Terraform prints outputs including the S3 bucket name and SNS topic ARNs.

### 5) Confirm SNS email subscriptions (IMPORTANT)

You will receive **two emails** from SNS (one for ingest, one for done).  
Open each email and click **Confirm subscription**.

If you do not confirm, you will not receive notifications.

### 6) Observe the pipeline running

Wait 2–5 minutes (depending on your schedule expression). You should see:

1. An **ingest** email every scheduled run (optional “proof” notification)
2. A **done** email from Lambda with GO/NO-GO decision
3. A report in S3 under:

```
s3://<artifact_bucket>/launch-window/YYYY/MM/DD/HHMMSSZ/mission=<mission>/launch_window_report.json
```

### 7) Verify in the AWS Console

- **EventBridge**: find the rule output `eventbridge_rule_name`
- **SNS**: confirm subscriptions
- **SQS**: check `ApproximateNumberOfMessages` (should stay near 0 once Lambda consumes)
- **Lambda**: open CloudWatch logs for `launch_eval` function
- **S3**: open the bucket and browse to the `launch-window/` prefix

---

## Key teaching moments (what to explain)

1. **EventBridge as a scheduler**
   - No servers, just a schedule
2. **SNS fan-out**
   - One event -> many subscribers
3. **SNS → SQS requires a queue policy**
   - Without it, SQS will reject sends
4. **SQS → Lambda via event source mapping**
   - Lambda polls and batches messages
5. **Audit artifact in S3**
   - Immutable run outputs you can share and review

---

## Optional stretch goals (if time allows)

1. Add an SQS **DLQ** and set `redrive_policy`
2. Write **CSV** in addition to JSON
3. Use `mission` to vary thresholds (site-specific constraints)
4. Add another EventBridge rule for a different mission payload

---

## Cleanup (avoid charges)

```bash
terraform destroy
```

> Note: S3 buckets with objects may block destroy. If so, empty the bucket first:
```bash
aws s3 rm s3://<artifact_bucket> --recursive
terraform destroy
```

---

## Troubleshooting

### I’m not getting emails
- Check you **confirmed** the SNS subscriptions.
- Check your spam folder.
- In SNS Console, ensure subscription status is **Confirmed**.

### SQS queue is filling up
- Check Lambda event source mapping exists and is enabled.
- Check Lambda logs for errors (permissions, JSON parsing, etc.)

### Terraform apply fails with name conflicts
- Change `project_name` in `terraform.tfvars` and retry.

---

## Security note
This workshop uses a simple, minimal IAM policy for the Lambda role scoped to:
- its SQS queue
- the artifact bucket prefix
- the done SNS topic

For production, you would further harden policies, add encryption, and add monitoring/alerting.
