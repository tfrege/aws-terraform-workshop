# Automated deployments in GitHub and GitLab

- [Automated deployments in GitHub and GitLab](#automated-deployments-in-github-and-gitlab)
- [GitHub Actions](#github-actions)
  - [IAM Role](#iam-role)
  - [GitHub Repo](#github-repo)
- [GitLab CI/CD](#gitlab-cicd)
  - [IAM Role](#iam-role-1)
  - [GitLab Repo configuration](#gitlab-repo-configuration)
- [Adding additional steps like checkov](#adding-additional-steps-like-checkov)


# GitHub Actions

## IAM Role
In the AWS Management account, create an IAM Role for GitHub to access the account.

The role should have the following permissions:
1. sts:AssumeRole
2. ecr:GetAuthorizationToken3. 
3. Any permission the Terraform code will need to properly create/update/read/destroy all resources

```yaml
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Statement1",
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": [
                "<IAM_ROLE_ARN>"
            ]
        },
        {
            "Sid": "AllowGitHubActionsGetAuthTOken",
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            # All Permissions Needed
        }
    ]
}
```

And the following trust policy:

```yaml
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::<AWS_ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:<YOUR_GITHUB_USER>/<YOUR_GITHUB_REPO>:*"
                }
            }
        }
    ]
}
```

## GitHub Repo

1. Create a repo in GitHub
2. Store 2 secrets under `Settings > Secrets and variables > Actions`:
   * `AWS_ROLE_ARN` (stores the ARN of the Role created previously)
   * `AWS_REGION` (name of the region, i.e. us-east-1)

![github-secrets.png](../img/github_actions_secrets.png)

3. Store the code in the repo inside a specific folder, like `source` or `src`.
4. Create the file `.github/workflows/action.yml` with the following contents:

```yaml
name: Terraform Deploy

on:
  push:
    branches: [main]

env:
  TF_VERSION: 1.6.0

jobs:
  terraform:
    name: Terraform
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: ${{ secrets.AWS_REGION }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Terraform Format
        run: terraform fmt -check
        working-directory: ./src
        continue-on-error: true

      - name: Terraform Init
        run: terraform init
        working-directory: ./src

      - name: Terraform Validate
        run: terraform validate
        working-directory: ./src

      - name: Terraform Plan
        id: plan
        run: terraform plan -no-color -out=tfplan
        working-directory: ./src
        continue-on-error: true

      - name: Terraform Apply
        run: terraform apply -auto-approve tfplan
        working-directory: ./src
```


The repo will look like this:
<br />

```
.
├── .github/
├────── workflows/
├───────── action.yml
└── src/
    └── the code is here
```

Now each time a code change is made in the `main` branch, the action will be executed.

It's recommended to branch the code and merge it into `main` via a pull request, but the code can also be directly changed in the main branch

Optionally, you can add an action to validate the changes before creating the zip file and uploading to S3.





# GitLab CI/CD

Additional requirement: have a GitLab runner configured.

## IAM Role
In the AWS Management account, create an IAM Role for GitHub to access the account.

The role should have the following permissions:
1. sts:AssumeRole
2. ecr:GetAuthorizationToken
3. Any permission the Terraform code will need to properly create/update/read/destroy all resources

```yaml
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Statement1",
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": [
                "<IAM_ROLE_ARN>"
            ]
        },
        {
            "Sid": "AllowGitHubActionsGetAuthTOken",
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            # All Permissions Needed
        }
    ]
}
```

And the following trust policy:

```yaml
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::AWS_ACCOUNT:oidc-provider/gitlab.example.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "gitlab.example.com:sub": "project_path:mygroup/myproject:ref_type:branch:ref:main"
        }
      }
    }
  ]
}
```

## GitLab Repo configuration

1. Create a repo in GiLab
2. Store 2 secrets under `Settings -> CI/CD -> Variables`:
   * `AWS_ROLE_ARN` (stores the ARN of the Role created previously)
   * `AWS_REGION` (name of the region, i.e. us-east-1)
3. Store the code in the repo inside a folder like `source` or `src`
4. Create the file `.gitlab-ci.yml` with the following contents:

```yaml
image:
  name: hashicorp/terraform:1.6.0
  entrypoint: [""]

stages:
  - validate
  - deploy

before_script:
  - apk add --no-cache python3 py3-pip
  - pip3 install awscli
  - >
    export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s"
    $(aws sts assume-role-with-web-identity
    --role-arn ${AWS_ROLE_ARN}
    --role-session-name "GitLabRunner-${CI_PROJECT_ID}-${CI_PIPELINE_ID}"
    --web-identity-token ${CI_JOB_JWT_V2}
    --duration-seconds 3600
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]'
    --output text))
  - cd src
  - terraform init

validate:
  stage: validate
  script:
    - terraform fmt -check
    - terraform validate
  only:
    - main

deploy:
  stage: deploy
  script:
    - terraform plan -out=tfplan
    - terraform apply -auto-approve tfplan
  only:
    - main
  environment:
    name: production
```

The repo will look like this:
<br />

```
.
├── .gitlab-ci.yml
└── src/
    └── the code is here
```

Now each time a code change is made in the `main` branch, the CICD pipeline will be executed.

It's recommended to branch the code and merge it into `main` via a pull request, but the code can also be directly changed in the main branch


# Adding additional steps like checkov
Optionally, you can add additional actions, like running `checkov` before `terraform apply`:

```yaml
# GitHub:
steps:
  - name: Checkout
    uses: actions/checkout@v4

  - name: Checkov Scan
    uses: bridgecrewio/checkov-action@master
    with:
      directory: src/
      framework: terraform
      soft_fail: false
```

```yaml
# GitLab:
stages:
  - security
  - validate
  - deploy

before_script:
  - cd src
  - terraform --version
  - terraform init

security:
  stage: security
  image: bridgecrew/checkov:latest
  before_script:
    - echo "Running security scan"
  script:
    - checkov -d src/ --framework terraform --compact
  only:
    - main
```




