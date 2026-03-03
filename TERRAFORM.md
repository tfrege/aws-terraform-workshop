# Terraform 200


## Format the code nicely


```bash 
    terraform fmt -recursive
```


## Ways to set values to the variables

### variables.tf
Set default values in each variable definition.


### Execution time through the terminal 

Overwrite any default value while executing the code (variables with no default set will be requested at run time):

```bash 
    terraform apply -var="lambda_name=my-launch-fn" -var="bucket=my-bucket-name"
```

### terraform.tfvars 

It's a good practice to leave specific values out of the variables.tf

```hcl
lambda_name   = "my-launch-fn"
bucket        = "lmy-bucket-name"

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



## Validations

Validations are good practice. You can validate the values your variables are taking:




## Modules

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

## Environments
Environments are excellent mechanisms to execute the same code base in different environments, and use
a different .tfvars file for each, remembering to pass it at time of execution.

```bash
    terraform workspace list
```


```bash
    terraform workspace new dev
```

```bash
    terraform workspace new qa
```

```bash
    terraform workspace select dev
    terraform apply -var-file="vars/dev.tfvars"    
```

```bash
    terraform workspace select qa
    terraform apply -var-file="vars/qa.tfvars"    
```



## Backend configuration
If used with the default configuration, Terraform creates and maintains the ``terraform.tfstate`` file in the 
machine running Terraform, but this can lead to lost files (i.e. if the EC2 is terminated), or different versions 
if multiple developers are running the same code.

Solution: Remote Backend.

Terraform supports remote backends such as S3.


## Scanning Tools

### checkov


