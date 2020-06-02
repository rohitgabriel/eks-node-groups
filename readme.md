![](https://github.com/rohitgabriel/eks-node-groups/workflows/Terraform/badge.svg)
### Infrastructure and Application Deployment in AWS
![Provisioning diagram](https://eittestappbucket1.s3-ap-southeast-2.amazonaws.com/github-testapp.PNG)<br/>

## Pre-Reqs
Need AWS keys<br/>
Assumes that the artifacts are available in a S3 bucket for deployment. The CI process is not part of this repo.<br/>

## Usage
Populate the vars.tf file or pass variables like below:<br/>
```
terraform init
terraform plan -var="AWS_ACCESS_KEY_ID=AWS access key" -var="AWS_SECRET_ACCESS_KEY=aws secret key" -var="AWS_REGION=aws region" -var="db_password=Password more than 8 chars"
terraform apply -var="AWS_ACCESS_KEY_ID=AWS access key" -var="AWS_SECRET_ACCESS_KEY=aws secret key" -var="AWS_REGION=aws region" -var="db_password=Password more than 8 chars" 
```

## Deployment Design
Creates VPC and Subnets<br/>
Creates Multi AZ PostgresQL Database<br/>
Creates a secret in AWS secret manager and stores database password<br/>
Creates IAM Role with access policies attached (S3, SecretManager, RDS) and maps to launch configuration<br/>
Creates Launch configuration and deploys Auto scaling group with 2 EC2 instances (max 3)<br/>
EC2 Instances bootstrap script connects to the database using the password from AWS Secret manager and loads tables <br/>
Creates security group to allow traffic appropriately to private subnets where database is running<br/>
Creates Load Balancer and connects to Auto scaling group<br/>

## Access application
Terraform apply will output the ELB DNS Name<br/>
***Wait 5 minutes or more, after the output is printed for the instances to initialize and for ELB health checks to pass<br/>
https://ELB DNS NAME:3000<br/>

## Destroy
terraform destroy -var="AWS_ACCESS_KEY_ID=AWS access key" -var="AWS_SECRET_ACCESS_KEY=aws secret key" -var="AWS_REGION=aws region"  -var="db_password=Password more than 8 chars" <br/>

# Todo
- Reimplement the aws_iam_policy resource using the data.aws_iam_policy_document (https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html)
- Split network resource (VPC) into a separate module
- Split the DB resource (RDS) into a separate module
- Use Security Group references e-iher than cidr block references in SG rules.