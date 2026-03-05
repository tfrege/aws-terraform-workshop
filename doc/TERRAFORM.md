Terraform 200

- [Providers](#providers)
- [Format the code nicely](#format-the-code-nicely)
- [Ways to set values to the variables](#ways-to-set-values-to-the-variables)
  - [variables.tf](#variablestf)
  - [Execution time through the terminal](#execution-time-through-the-terminal)
  - [OS Environment variables](#os-environment-variables)
  - [terraform.tfvars](#terraformtfvars)
- [Tagging Resources](#tagging-resources)
- [Validations](#validations)
- [Modules](#modules)
- [Outputs](#outputs)
- [Built-in Functions](#built-in-functions)
- [Loops](#loops)
- [data and locals](#data-and-locals)
- [Environments](#environments)
- [Backend configuration](#backend-configuration)
- [Useful add-ons](#useful-add-ons)


# Providers
A provider is a plugin that acts as a bridge between the core Terraform application and the APIs of various cloud providers, SaaS services, and other platforms.

Every Terraform project needs at least 1 provider defined.

Most basic declaration:
```hcl
# The provider will inherit the IAM Role used by the EC2 instance. 
# That role must have all the required permissions for the Terraform code to work.
provider "aws" {
  region = "us-west-2"
}
```

Specifying the way to authenticate into the AWS Account:
```hcl
# Specifying an IAM Role:
provider "aws" {
  region = "us-west-2"
  assume_role {
    role_arn = "<ROLE_ARN_HERE>"
  }
}

# Specifying IAM user keys (not recommended):
provider "aws" {
  region = "us-west-2"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}

# Specifying an IAM Role and Region defined as variables:
provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = var.aws_role_arn
  }
}
```



Specifying multiple providers:
```hcl
provider "aws" {
  alias = "aws_dev_account"
  region = var.aws_region
  assume_role {
    role_arn = var.aws_role_arn_dev_account
  }
}

provider "aws" {
  alias = "aws_qa_account"
  region = var.aws_region
  assume_role {
    role_arn = var.aws_role_arn_qa_account
  }
}

# And when provisioning resources:
resource "aws_lambda_function" "launch_eval" {
  provider      = aws.aws_qa_account
  function_name = "${local.project_name}-launch-eval"
  role          = aws_iam_role.lambda_role.arn
}
```

Specifying multiple providers for different Cloud Platforms:
```hcl
provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = var.aws_role_arn_qa_account
  }
}

provider "google" {
  project = "your-gcp-project-id" 
  region  = "us-central1"         
  zone    = "us-central1-c"       
}
```


# Format the code nicely


```command 
    terraform fmt -recursive
```


# Ways to set values to the variables

## variables.tf
Set default values in each variable definition.

```hcl
variable "project_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "launch-window-workshop"
}

variable "max_wind_kts" {
  description = "Maximum allowable wind speed (knots) for GO decision"
  type        = number
  default     = 20
}
```

## Execution time through the terminal

Overwrite any default value while executing the code (variables with no default set will be requested at run time):

```command 
    terraform apply -var="project_name=launch-time" -var="max_wind_kts=25"
```

## OS Environment variables

The environment variable must start with `TF_VAR_` and follow with the name defined in the code:

```command
export TF_VAR_project_name="launch-time"
export TF_VAR_max_wind_kts=25
```

## terraform.tfvars

It's a good practice to leave specific values out of the variables.tf

```hcl
project_name  = "launch-time"
bucket        = "lmy-bucket-name"
done_email    = "YOUR_EMAIL@example.com"
schedule_expression  = "rate(2 minutes)"
max_wind_kts         = 20
min_cloud_ceiling_ft = 2500
lightning_allowed    = false
range_allowed        = "GREEN"
```


# Tagging Resources

Tag, always tag. Each AWS resource supports up to 50 {key, value} tags.

```hcl
resource "aws_lambda_function" "launch_eval" {
  function_name = "${local.project_name}-launch-eval"
  role          = aws_iam_role.lambda_role.arn
  
  tags = {
    Team        = "Engineering"
    Environment = "dev"
    CostCenter  = "12345"
  }
}
```

Terraform supports assigning default tags to all resources of a project. These must be defined in the provider:

```hcl
provider "aws" {
  region  = "us-east-1"

  default_tags {
    tags = {
        Team        = "Engineering"
        Environment = "dev"
        CostCenter  = "12345"
    }
  }
}
```

You can combine default tags with specific tags for specific resources:
```hcl
# This resource will inherit all the tags defined by its provider, plus get additional ones set
resource "aws_lambda_function" "launch_eval" {
  function_name = "${local.project_name}-launch-eval"
  role          = aws_iam_role.lambda_role.arn
  
  tags = {
    Module      = "MissionOperations"
    Layer       = "Application"
    CostCenter  = "67890"       # This means the default tag will be overwritten for this resource
  }
}
```


# Validations

Validations are good practice. You can validate the values your variables are taking.
Here are a few examples:

```hcl
# Validate a variable has a minimum of N chars
variable "env" {
  type        = string
  description = "Environment (DEV, QA, PROD, etc.)"
  validation {
    condition     = length(var.env) > 1
    error_message = "Enter an environment name equal or longer than 2 chars."
  }
}

# Validate a region belongs to a finite list
variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Select one of the following: us-east-1, us-east-2, us-west-1, us-west-2"
  validation {
    condition = contains(["us-east-1", "us-east-2", "us-west-1", "us-west-2"], var.region)
    error_message = "Error: The region is incorrect."
  }
}

# Regex to validate a string is properly formatted. Specially useful when passing ARNs
variable "kms_key_arn" {
  type        = string
  description = "ARN of the KMS key"
  default     = "arn:aws:kms:<REGION_ID>:<ACCOUNT_ID>:key/<KMS_ID>"

  validation {
    condition     = can(regex("^arn:aws:kms:[a-z][a-z]-[a-z]+-[1-9]:[[:digit:]]{12}:key/.+", var.kms_key_arn))
    error_message = format("The KMS key ARN (%s) is invalid.", var.kms_key_arn)
  }
}

# List has at least 1 value
variable "sources_list" {
  type        = map(any)
  description = "List of objects where each element is a source to create."
  validation {
    condition     = length(var.sources_list) > 0
    error_message = "Provide at least 1 element to the list of Sources to create."
  }
}

# The value belongs to a defined list of options
variable "archive_storage_class" {
  type        = string
  description = "Storage class to use for archival of files."
  default     = "DEEP_ARCHIVE"

  validation {
    condition     = can(regex("^(STANDARD|STANDARD_IA|GLACIER|DEEP_ARCHIVE)$", var.archive_storage_class))
    error_message = format("Invalid input for archive_storage_class, options are: \"STANDARD\", \"STANDARD_IA\", \"GLACIER\", \"DEEP_ARCHIVE\" (value given: %s).", var.archive_storage_class)
  }
}
```


# Modules

While you can have your entire code in one main.tf file, it is recommended to split it in different files,
usually based on the type of resource that will be deployed:

```
.
├── eventbridge.tf
├── lambda.tf
├── s3.tf
├── sns.tf
├── provider.tf
└── lambda
    └── handler.py
```

Even better, you can have _modules_, and invoke each from the main.tf file (which is known as the _root_ module):

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
├── modules/
├────── eventbridge/
├────────── main.tf
├────────── outputs.tf
├────────── variables.tf
├────── lambda/
├────────── main.tf
├────────── outputs.tf
├────────── variables.tf
├────── s3/
├────────── main.tf
├────────── outputs.tf
├────────── variables.tf
├────── sns/
├────────── main.tf
├────────── outputs.tf
├────────── variables.tf
```

The `main.tf` in the root folder is known as the **root module** and is the one that invokes the others:

```hcl
module "newLambda" {
  source                    = "./modules/lambda"
  name                      = format("%s-%s-lambda", var.project_name, var.environment)
  iam_role                  = module.lambdaRole.iam_role_arn
}

module "newBucket" {
  source                    = "./modules/s3"
  name                      = format("%s-%s", var.project_name, var.environment)
}
```


# Outputs

Similar to `variables.tf` which define the ingress values for a Terraform project, `outputs.tf` defines 
the list of outputs. It is optional, but useful when working with modules.

```hcl
output "lambda_function_arn" {
  value       = aws_lambda_function.my_func.arn
  description = "ARN of the new Lambda function."
}
```

Passing the output of one module as the input of another:
```hcl
# In ./modules/iam/role:
output "iam_role_arn" {
  value       = aws_iam_role.new_role.arn
  description = "ARN of the new IAM Role."
}

# In main.tf, when invoking the modules:

module "lambdaRole" {
  source                    = "./modules/iam/role"
  name                      = format("%s-%s-role", var.project_name, var.environment)
}

module "newLambda" {
  source                    = "./modules/lambda"
  name                      = format("%s-%s-lambda", var.project_name, var.environment)
  iam_role                  = module.lambdaRole.iam_role_arn
}
```

# Built-in Functions 

Some examples of useful methods that can be used to transform variables.
For full details, see [TERRAFORMFUNCTIONS](./doc/TERRAFORM-FUNCTIONS.md) and the [Official Terraform website](https://developer.hashicorp.com/terraform/language/functions).


| Function | Description | Example |
------------ | ----------- | ----------- |
| `format(spec, values...)` | Formats string using printf-style syntax | `format("Hello, %s!", "World")` → `"Hello, World!"` |
| `lower(string)` | Converts string to lowercase | `lower("HELLO")` → `"hello"` |
| `regex(pattern, string)` | Matches regex pattern in string | `regex("[a-z]+", "abc123")` → `"abc"` |
| `replace(string, search, replace)` | Replaces occurrences in string | `replace("hello", "l", "L")` → `"heLLo"` |
| `substr(string, offset, length)` | Extracts substring | `substr("hello", 1, 3)` → `"ell"` |
| `upper(string)` | Converts string to uppercase | `upper("hello")` → `"HELLO"` |
| `ceil(number)` | Rounds up to nearest integer | `ceil(4.3)` → `5` |
| `max(numbers...)` | Returns maximum value | `max(5, 12, 9)` → `12` |
| `min(numbers...)` | Returns minimum value | `min(5, 12, 9)` → `5` |
| `flatten(list)` | Flattens nested lists | `flatten([[1,2], [3,4]])` → `[1,2,3,4]` |
| `sort(list)` | Sorts list alphabetically | `sort(["c", "a", "b"])` → `["a", "b", "c"]` |
| `sum(list)` | Sums numeric list | `sum([1, 2, 3])` → `6` |
| `formatdate(format, timestamp)` | Formats timestamp | `formatdate("YYYY-MM-DD", timestamp())` → `"2024-01-15"` |
| `timestamp()` | Returns current timestamp | `timestamp()` → `"2024-01-15T10:30:00Z"` |
| `tonumber(value)` | Converts to number | `tonumber("42")` → `42` |
| `tostring(value)` | Converts to string | `tostring(42)` → `"42"` |


# Loops

Simple List Iteration using `count`:

```hcl
variable "instance_names" {
  default = ["web-1", "web-2", "web-3"]
}

resource "aws_instance" "server" {
  count         = length(var.instance_names)
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  tags = {
    Name = var.instance_names[count.index]
  }
}
```

Conditional Resource Creation:

```hcl
variable "create_instance" {
  default = true
}

resource "aws_instance" "server" {
  count         = var.create_instance ? 1 : 0
  ami           = "ami-12345678"
  instance_type = "t2.micro"
}

# Access: aws_instance.server[0] (if created)
```



# data and locals

Data helps retrieve existing resources. Examples:
* You need to know the ID of the AWS Account where the resources are being deployed,
* You need the AWS region
* The AWS partition (aws or aws-us-gov)
* The data of a resource that will be used to deploy the news ones, such as:
  * The list of subnets for a given VPC
  * All the data associated to a Lambda function


Working with AWS data:
```hcl
# Look up the current AWS account identity
data "aws_caller_identity" "current" {}

# Look up the current AWS region
data "aws_region" "current" {}

# Look up the current AWS partition
data "aws_partition" "current" {}

# In the resources provisioning:

# To produce the name as "mybucket-1090392029-us-west-2". It helps secure unique identifiers.
resource "aws_s3_bucket" "artifacts" {
    bucket = format("mybucket-%s-%s", data.aws_caller_identity.current.account_id, data.aws_region.current.name)
}
```

Obtaining the private subnets of a given VPC ID:
```hcl
data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    "tier" = "private"
  }
}
```

Passing data as a parameter for a new resource:
```hcl
data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  tags = {
    "tier" = "public"
  }
}

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.your_security_group_id
  subnets            = data.aws_subnets.public_subnets.ids
}
```

```hcl
data "aws_lambda_function" "existing" {
  function_name = "name-of-your-existing-lambda"
   Optional: specify a qualifier (alias or version number)
   qualifier     = "$LATEST"
}

output "the_function_memory_size" {
  value = data.aws_lambda_function.existing.memory_size
}

output "the_function_role" {
  value = data.aws_lambda_function.existing.role
}
```


# Environments
Environments are excellent mechanisms to execute the same code base in different environments, and use
a different .tfvars file for each, remembering to pass it at time of execution.

```command 
    terraform workspace list
```


```command 
    terraform workspace new dev
```

```command 
    terraform workspace new qa
```

```command 
    terraform workspace select dev
    terraform apply -var-file="vars/dev.tfvars"    
```

```command 
    terraform workspace select qa
    terraform apply -var-file="vars/qa.tfvars"    
```



# Backend configuration
If used with the default configuration, Terraform creates and maintains the ``terraform.tfstate`` file in the 
machine running Terraform, but this can lead to lost files (i.e. if the EC2 is terminated), or different versions 
if multiple developers are running the same code.

Solution: Remote Backend.

Terraform supports remote backends such as S3.

```hcl
terraform {
  backend "s3" {
    bucket         = "your-unique-terraform-state-bucket"
    key            = "path/to/your/environment/terraform.tfstate"
    region         = "us-east-1"
    # Optional: Enable server-side encryption
    encrypt        = true
    # Optional: For state locking, specify a DynamoDB table
    dynamodb_table = "your-terraform-locks"
  }
}
```


# Useful add-ons

 See [ADDONS](ADDONS.md) for details on:

* checkov: [Checkov](https://www.checkov.io/) is a great tool to scan your code and detect security vulnerabilities.
* terraform-docs: Generates documentation for your Terraform code. It produces a better document if the variables and outputs
are well documented.
