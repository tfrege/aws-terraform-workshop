# Checkov and terraform-docs

## Checkov

### Install

```bash
# Update system packages
sudo yum update -y

# Install Python 3 and pip
sudo yum install -y python3 python3-pip

# Install Checkov
pip3 install checkov

# Verify installation
checkov --version
```

### Run

```bash
# Navigate to your Terraform project directory
cd /path/to/terraform/project

# Run Checkov and output results to a file
checkov -d . -o json > checkov-results.json

# Or output in multiple formats
checkov -d . -o cli -o json --output-file-path . --output-file-name checkov-report
```

### Common Output Formats

- `cli` - Console output (default)
- `json` - JSON format
- `junitxml` - JUnit XML format
- `sarif` - SARIF format
- `github_failed_only` - GitHub format (failed checks only)

### Example: Scan Specific Directory with JSON Output

```bash
checkov -d /home/ec2-user/terraform --framework terraform -o json > /home/ec2-user/checkov-scan-results.json
```

## terraform-docs

### Install

```bash
# Download terraform-docs
wget https://github.com/terraform-docs/terraform-docs/releases/download/v0.17.0/terraform-docs-v0.17.0-linux-amd64.tar.gz

# Extract the binary
tar -xzf terraform-docs-v0.17.0-linux-amd64.tar.gz

# Move to PATH
sudo mv terraform-docs /usr/local/bin/

# Verify installation
terraform-docs --version
```

### Run and generate README.md

```bash
# Navigate to your Terraform project directory
cd /path/to/terraform/project

# Generate README.md
terraform-docs markdown table . > README.md

# Or generate with custom template
terraform-docs markdown . --output-file README.md
```
