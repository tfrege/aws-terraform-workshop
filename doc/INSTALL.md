# Installing required tools

## Terraform

```command 
sudo dnf update -y
```

```command 
sudo dnf install -y yum-utils
```

Add the official HashiCorp repository for Amazon Linux:

```command 
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
```


```command 
sudo dnf install -y terraform
```

Verify the installation:

```command 
terraform -version
```
