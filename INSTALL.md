# Installing required tools

## Terraform

```bash
sudo dnf update -y
```

```bash
sudo dnf install -y yum-utils
```

Add the official HashiCorp repository for Amazon Linux:

```bash
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
```


```bash
sudo dnf install -y terraform
```

Verify the installation:

```bash
terraform -version
```


```bash
```
