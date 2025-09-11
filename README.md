# Multi Tier Highly Scalable Web Application

## Description

This GitLab Repository is dedicated for my Terraform Final Activity in my internship in Stratpoint. In this repository, I will showcase to you guys how to deploy and manage a Multi Tier Highly Scalable Web Application in AWS using Terraform. 

## Requirements 

### Architecture Diagram

Here is the architecture diagram for this project: 

![System Architecture](../output/TerraformDiagram.png)

### Resources

1. VPC
    - CIDR - 10.0.0.0/16
    - 2 Public Subnet (AZ1, AZ2)
        - 10.0.1.0/24
        - 10.0.2.0/24
    - 4 Private Subnet (AZ1, AZ2)
        - 10.0.3.0/24
        - 10.0.4.0/24
        - 10.0.5.0/24
        - 10.0.6.0/24
    - 1 Internet Gateway
    - 1 NAT gateway deployed in AZ2 public subnet

2. EC2 for Bastion Host
    - t2.micro
    - Amazon Linux AMI

3. AutoScaling group
    - ASG 1 for frontend
        - Minimum: 2
        - Maximum: 4
        - Desired: 2
        - Scaling rule to scale out if CPUUtilization >= 40% for 1 minute
        - Scaling rule to scale in if CPUUtilization <= 10% for 1 minute
        - Userdata - [Userdata for Frontend](../terraformProject/root/modules/frontend/frontend_userdata.sh)
    - ASG 2 for backend
        - Minimum: 2
        - Maximum: 4
        - Desired: 2
        - Scaling rule to scale out if CPUUtilization >= 40% for 1 minute
        - Scaling rule to scale in if CPUUtilization <= 10% for 1 minute
        - Userdata - [Userdata for Backend](../terraformProject/root/modules/backend/backend_userdata.sh)

> If the EC2 instance is unhealthy in the target group/load balancer, ASG should replace the instance

4. Application Load Balancers
    - Frontend ALB - Internet-facing
    - Backend ALB - Internal
    > Use HTTP Protocol and Port 80 for Listeners

5. S3 Bucket + DynamoDB
    - S3 for Terraform statefile
    - DynamoDB for Terraform statelock

6. Security Groups
    - Resources in the public subnet are open to all, while resources in the private subnet should be accessible from the bastion host only

## Execution

Follow this steps when executing this project
1.  Clone and explore the repository.

    ```bash
    # clone through ssh
    git clone git@github.com:MHSoquiat/terraformProject.git
    
    #clone through http
    git clone https://github.com/MHSoquiat/terraformProject.git

    # change directory
    cd terraformProject

    # list and check the files
    dir
    # output                    - Folder containing images of expected outputs displayed in README.md
    # root                      - Folder containing the main configuration file and modules
    # statefile-statelocking    - Folder containing the configuration file for statefile and state locking
    # .gitignore                - File containing list of files ignored in git commands
    # README.md                 - File containing sets of information, instructions, and details about the repository.
    ```

2. Run the `statefile-statelocking` configuration file using the following execution commands 

    ```bash
    # change directory
    cd terraformProject/statefile-statelocking

    # This command will initialize your folder and terraform to install the necessary extensions for the task required
    terraform init

    # This command will layout all the resources that terraform will deploy in your account
    terraform plan

    # This command will deploy all the resources to your AWS account
    terraform apply
    ```

>[!WARNING]
>Before executing terraform init, ensure that you already have terraform set up in your local device, otherwise, it will not work

>[!NOTE]
>Before executing terraform plan, ensure that you already have your Access Key and Secret Access Key ready. It will be asked during the running process for security measures.

If you don't have `terraform` set up in your local device, follow this documentation:

:point_right: [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

Here are the expected outputs for this step:

Terraform Init: 

![Terraform Init](../output/init-ss.png)

Terraform Plan:

![Terraform Plan](../output/plan-ss.png)

Terraform Apply: 

![Terraform Apply](../output/apply-ss.png)

3. Create a backend.hcl file in the root folder, and paste this code snippet:

    ```hcl
    bucket = "soki-s3"
    key = "dev/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "soki-db"
    encrypt = true
    ```

>[!NOTE]
> Feel free to change the values in your own backend.hcl file, just make sure that it matches to names of the resources that you created and the region as to where you deployed your system.

4. Run the `root` folder with the use of the following commands:

    ```bash
    # change directory from statefile-statelocking folder
    cd ../root

    # This command will initialize your folder and terraform to install the necessary extensions for the task required, make sure to create your own backend.hcl file containing all the necessary information for s3, dynamodb, and region
    terraform init -backend-config=backend.hcl

    # This command will layout all the resources that terraform will deploy in your account
    terraform plan

    # This command will deploy all the resources to your AWS account
    terraform apply
    ```

>[!CAUTION]
> Terraform apply will not work unless you set up your own keypair. Make sure to create your own and replace the value of the key_name in the following modules' variable files: backend, bastion-host, and frontend.

Here are the expected output for this step:

Terraform Init: 

![Terraform Init](../output/init-r.png)

Terraform Plan:

![Terraform Plan](../output/plan-r.png)

Terraform Apply: 

![Terraform Apply](../output/apply-r.png)

:white_check_mark: Great! Now you have successfully deployed your own Multi Tiered Web Application in AWS using Terraform. For the next steps, check out for the following features:

## Features

Test the following features for this System:

- [] Access Bastion Host through SSH
- [] Access EC2 instances deployed in Auto Scaling group through the Bastion Host
- [] Access the Web Application by using the Frontend Application Load Balancer DNS Name
- [] Stress test an EC2 instance to increase or decrese the value of CPUUtilization to test Auto Scaling Group
- [] Kill or Manually force an EC2 instance to be unhealthy to test Application Load Balancer and Auto Scaling Group

> This project is continuously updated and maintained to accommodate changes in AWS and Terraform

If you like this repository, let's connect on the following social media platforms:
- :point_right: [LinkedIn](https://www.linkedin.com/in/soqwapo/)
- :point_right: [Instagram](https://www.instagram.com/soqwapo/)
