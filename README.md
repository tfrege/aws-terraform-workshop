# aws-terraform-workshop
Workshop to learn the basics of AWS and Terraform while deploying a small serverless application.


# Application



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
├── variables.tf
├── outputs.tf
├── versions.tf
├── provider.tf
└── lambda
    └── handler.py
```

# Terraform 101

## Key components of any TF deployment 

* main.tf
  This is where the resources will be specified.

* provider 
  This tells Terraform where it will deploy the resources (i.e. AWS Account, Azure, GCP, etc.) and the 
  permissions it requires.

* variables
  This file specifies the variables the resources will need (i.e. the name of a bucket). 

* outputs
  Optional: it lists key information about the resources provisioned.


* data 
  Optional: useful to recover information of existing resources, such as:
  - The AWS Account ID 
  - The selected region 
  - The partition (aws or aws-us-gov)
  - Resources that already exist and that will be needed for the new ones (i.e. VPC ID if you're creating a Subnet)

* locals 
  Optional: blocks of code to perform calculations and create new variables.


## initialize terraform

```bash 
    terraform init
```

## validate the code 

```bash 
    terraform validate
```

## plan the deployment

```bash 
    terraform plan
```

## deploy the code

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

Once the _apply_ completes, go to the AWS Console --> Lambda --> Functions and find your Lambda. 

Create a new Test Event.

And execute the function.


## Storing the results in an Amazon S3 Bucket 

Open the file terraform --> lambda --> handler.py file and add the following piece:


```python 
```

Save the changes and re-deploy the solution:

```bash 
    terraform apply -auto-approve
```

Wait until it completes, go back to the Console, verify the changes are there, and re-test the function.

It fails.


## Why it failed: add the permissions needed to the IAM Role

It failed because, even though Lambda can interact well with S3, it needs the permissions to do it.
AWS follows the principle of least privilege: every resource (user, bucket, function, etc.) has no 
permissions to invoke another or perform changes. Any action must be allowed in its Role.

Go to the Terraform repo and open the file terraform --> main.tf 

Find the resource ``aws_iam_policy`` ``lambda_policy`` and add this block of code:


```json 

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

Open the ``main.tf`` file and add this block:

```hcl 

```

Save the changes and re-deploy:


```bash 
    terraform apply -auto-approve
```

 Go to the console and open EventBridge. Find your schedule.

 You can wait for the 5 mins to pass.

 One way to validate the Lambda has been executed is looking at ``CloudWatch logs``:




## Notifying the users when the execution completes

Now let's add a notification when the Lambda finishes, sending the results to an e-mail address.



Open the ``main.tf`` file and add this block:

```hcl 

```

Save the changes and re-deploy:


```bash 
    terraform apply -auto-approve
```




## More advanced Terraform concepts

See TERRAFORM.md



