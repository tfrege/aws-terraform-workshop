# Terraform 200


## Format the code nicely



## Ways to set values to the variables

### variables.tf


### Execution time through the terminal 


### terraform.tfvars 

It's a good practice to leave specific values out of the variables.tf

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



## Validations




## Environments



## Backend configuration



## Scanning Tools

### checkov


