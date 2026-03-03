# aws-terraform-workshop
Workshop to learn the basics of AWS and Terraform while deploying a small serverless application.


# Application

This small application calculates a GO/NO GO for launching a -----------

<img src="img/architecture.png">



# Set up your environment 

## Login to the AWS Console 


## Start a session in the EC2 instance 


And make sure you are in the $HOME directory:

```bash 
    cd $HOME
```


## Get a copy of the base code
For the purpose of this Workshop, the code is located in this S3 Bucket:

```bash 
aws-terraform-workshop
```

Copy it to the EC2 running this command:

```bash
    aws s3 cp s3://aws-terraform-workshop/launch-window.zip .    
```

And then unzip the file:
```bash
    unzip launch-window.zip .
```

### Repo structure

```
.
├── main.tf
├── provider.tf
└── lambda
    └── handler.py
```

# Terraform 101

## initialize terraform

The `terraform init` command initializes a working directory containing configuration files and installs plugins for required providers.

```bash 
    terraform init
```

## validate the code 

The terraform validate command validates the configuration files in a directory. It does not validate remote services, such as remote state or provider APIs.

```bash 
    terraform validate
```

## plan the deployment

The `terraform plan` command creates an execution plan with a preview of the changes that Terraform will make to your infrastructure.

```bash 
    terraform plan
```

## deploy the code

The `terraform apply` command executes the actions proposed in a Terraform plan to create, update, or destroy infrastructure.

```bash 
    terraform apply
```

Type `yes` when asked for confirmation and wait for the code to deploy.


## Verify in the AWS Console

Go to the AWS Console and search for the Lambda function.


# Terraform 102

## Modifying the deployment

Go back to the ``main.tf`` file and change the name of your function.

Before applying any change, run a plan to verify that only the name will be changed:

```bash 
    terraform plan
```

And if everything looks good, apply the changes:

```bash 
    terraform apply
```

## Destroying the deployment 

```bash 
    terraform destroy
```

Which is the equivalent of:


```bash 
    terraform apply -destroy
```

## Apply or destroy without waiting for confirmation
Add the ``-auto-approve`` option:


```bash 
    terraform apply -auto-approve
```


# Application 

## First deployment

The code base is setup to deploy a Lambda function called launch-window.

Once the `apply` completes, go to the `AWS Console --> Lambda --> Functions` and find your Lambda. 

Create a new Test Event.

And execute the function.


## Storing the results in an Amazon S3 Bucket 

Open the file `terraform --> lambda --> handler.py` file and add the following piece:


```python 
```

Now open the main.tf file and add this blocks:

```hcl 
    # -----------------------------
    # S3 bucket for audit artifacts
    # -----------------------------
    resource "aws_s3_bucket" "artifacts" {
    bucket = lower("${local.name_prefix}-artifacts")
    tags   = local.tags
    }

    resource "aws_s3_bucket_versioning" "artifacts" {
        bucket = aws_s3_bucket.artifacts.id
        versioning_configuration {
            status = "Enabled"
        }
    }
```

Save the changes and re-deploy the solution:

```bash 
    terraform apply -auto-approve
```

Wait until it completes, go back to the Console, verify the changes are there:
* A new S3 bucket has been created
* The Lambda code contains the new block 
 
Re-test the function.


*:x: It fails*


## Why it failed

It failed because, even though Lambda can interact well with S3, it needs the permissions to do it.
AWS follows the principle of least privilege: every resource (user, bucket, function, etc.) has no 
permissions to invoke another or perform changes. Any action must be allowed in its Role.

Go to the Terraform repo and open the file `terraform --> main.tf` 

Find the block ``data "aws_iam_policy_document" "lambda_policy"`` and add this block of code:


```hcl 
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.artifacts.arn}/*"]
  }
```

The entire block should look like:

```hcl 
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
            "s3:PutObject"
            ]
            resources = ["${aws_s3_bucket.artifacts.arn}/*"]
        }
    }
```


Save the changes and re-deploy:


```bash 
    terraform apply -auto-approve
```

Go to the console and re-test the Lambda.

Once it completes, find the S3 bucket and verify a file has been created.


## Automating the execution of the Lambda function with EventBridge

The solution works great, but it requires a person to execute it on demand.

We'll add an Event Bridge schedule that will execute the function every 5 minutes.

Open the `main.tf` file and add this block:

```hcl 


```

Save the changes and re-deploy:


```bash 
    terraform apply -auto-approve
```

 Go to the console and open EventBridge. Find your schedule.

 You can wait for the 5 mins to pass.

 One way to validate the Lambda has been executed is looking at `CloudWatch logs`:




## Notifying the users when the execution completes

Now let's add a notification when the Lambda finishes, sending the results to an e-mail address.



Open the `main.tf` file and add this block:

```hcl 
    # -----------------------------
    # SNS Topic
    # -----------------------------
    resource "aws_sns_topic" "done" {
        name = "${local.name_prefix}-done"
        tags = local.tags
    }

    # Email subscriptions (require confirmation by clicking link in email)    
    resource "aws_sns_topic_subscription" "done_email" {
        topic_arn = aws_sns_topic.done.arn
        protocol  = "email"
        endpoint  = var.done_email
    }
```


Also, let's make sure the Lambda will have the required permissions to publish messages to this new topics.
In the block ``data "aws_iam_policy_document" "lambda_policy"``:

```hcl 
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
```


Save the changes and re-deploy:


```bash 
    terraform apply -auto-approve
```

## Remove all hardcoded values and turn them into variables

Hardcoded values are always bad practice.

Create a file named `variables.tf` and copy this code:

```hcl 

variable "mission" {
  description = "Mission name included in the scheduled payload"
  type        = string
  default     = "DEMO-1"
}

variable "launch_site" {
  description = "Launch site identifier included in the scheduled payload"
  type        = string
  default     = "KSC"
}

variable "vehicle" {
  description = "Vehicle identifier included in the scheduled payload"
  type        = string
  default     = "LV-A"
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
```


Now we'll replace all our hardcoded values for these variables in `main.tf`:

Inside the definition of the Lambda function (`resource "aws_lambda_function" "launch_eval"`):

```hcl 
  environment {
    variables = {
      ARTIFACT_BUCKET          = aws_s3_bucket.artifacts.bucket
      DONE_TOPIC_ARN           = aws_sns_topic.done.arn
      MAX_WIND_KTS             = tostring(var.max_wind_kts)
      MIN_CLOUD_CEILING_FT     = tostring(var.min_cloud_ceiling_ft)
      LIGHTNING_ALLOWED        = tostring(var.false)
      RANGE_ALLOWED            = var.range_allowed
      ARTIFACT_PREFIX          = "launch-window"
    }
  }

```


## More advanced Terraform concepts

See TERRAFORM.md



