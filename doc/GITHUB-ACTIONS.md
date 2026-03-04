# github-actions-s3
How to use GitHub actions to zip the code in the repo and copy it to a given S3 Bucket.
Useful for the deployment of the AWS Landing Zone Accelerator (LZA).



![diagram.png](img/diagram.png)

# Requirements
1. S3 Bucket where the zip file will be copied, i.e. `aws-accelerat﻿or-config-123456789011`
2. IAM Role in AWS that grants GitHub permissions to be assumed and to deploy the resources
3. Repository in GitHub




## IAM Role
In the AWS Management account, create an IAM Role for GitHub to access the account.

The role should have the following permissions:
1. sts:AssumeRole
2. ecr:GetAuthorizationToken
3. s3:putObject

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
                "<ARN_OF_IAM_ROLE>"
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
            "Sid": "AllowUploadToS3",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "*"
            ]
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
                    "token.actions.githubusercontent.com:sub": "repo:<YOUR_GITHUB_ORG_OR_USER>/<YOUR_GITHUB_REPO>:*"
                }
            }
        }
    ]
}
```

## GitHub Repo

1. Create a repo in GitHub
2. Store 3 secrets under Settings > Secrets and variables > Actions:
   * AWS_ASSUME_ROLE (stores the ARN of the Role created previously)
   * AWS_REGION (name of the region, i.e. us-east-1)
   * S3_BUCKET_NAME (name of the S3 bucket where the zip file will be uploaded)

![github-secrets.png](img/github_secrets.png)



3. Store the LZA code inside a folder named `aws-accelerator-config`

4. Create the file `.github/workflows/action.yml` with the following contents:

```yaml
nname: Zip and Upload Zipped Directory to S3
on:
  push:
    branches:
      - main
jobs:
  build:
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
          aws-region: ${{ secrets.AWS_REGION }}
          role-to-assume: ${{ secrets.AWS_ASSUME_ROLE }}        
        
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: 3.x
          
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install awscli
          
      - name: Archive code
        run: zip -r aws-accelerator-config.zip aws-accelerator-config/
        
      - name: Upload to S3
        env:
          AWS_REGION: ${{ secrets.AWS_REGION }}
          S3_BUCKET_NAME: ${{ secrets.S3_BUCKET_NAME }}
        run: >
          aws s3 cp ./aws-accelerator-config.zip
          s3://$S3_BUCKET_NAME/zipped/aws-accelerator-config.zip
        
```


The repo will look like this:
<br />
![github_repo_with_action.png](img/github_repo_with_action.png)


Now each time a code change is made in the `main` branch, the action will be executed.

It's recommended to branch the code and merge it into `main` via a pull request, but the code can also be directly changed in the main branch


