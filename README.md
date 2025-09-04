# Three Tier Highly Scalable Web Application

## Description

This GitLab Repository is dedicated for my Terraform Final Activity

## Execution

Follow this steps when executing this project
1. Navigate to ```statefile-statelocking``` folder
2. Run the execution commands 

To execute the folders in this repository, run this commands in your command line:
```
terraform init
terraform plan
terraform apply
```
>[!NOTE]
>Before Initializing terraform plan, ensure that you already have your Access Key and Secret Access Key ready. It will be asked during the running process for security measures.

## Resources
```
VPC
2 Private Subnet
2 Public Subnet
1 Internet Gateway
```

## Specifications

### VPC Specifications
- CIDR: 10.0.0.0/16
- Public Subnet:
    - 10.0.1.0/24
    - 10.0.2.0/24
- Private Subnet:
    - 10.0.3.0/24
    - 10.0.4.0/24
- Internet Gateway
