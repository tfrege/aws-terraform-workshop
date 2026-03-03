# aws-terraform-workshop
Workshop to learn the basics of AWS and Terraform while deploying a small serverless application.


# Application



# Set up your environment 

## Login to the AWS Console 


## Start a session in the EC2 instance 


## Get a copy of the base code
For the purpose of this Workshop, the code is located in this S3 Bucket:

```bash 
aws-terraform-workshop
```

Copy it to the EC2 running this command:

````

And then unzip the file:

````

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

* main file

* provider 
* variables
* output
* data 
* locals 



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


## Verify in the AWS Console



# Terraform 102

## Modifying the deployment


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


## Why it failed: add the permissions needed to the IAM Role


## Automating the execution of the Lambda function with EventBridge


## Notifying the users when the execution completes


## Storing the results in an Amazon S3 Bucket 






## More advanced Terraform concepts

See TERRAFORM.md



