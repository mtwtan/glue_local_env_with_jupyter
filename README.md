# Creating a Jupyter Notebook environment for running AWS Glue ETL scripts locally on an AWS EC2 Instance
A local development environment to run AWS Glue ETL scripts with a Jupyter Notebook server and made available over https.

## Pre-requisites
- This setup assumes that users are using AWS
- An available VPC with a subnet that is available over the public internet with an Internet Gateway.
- Have an available and appropriate SSL/TLS cert

## WORK IN PROGRESS
### CloudFormation template in progress

## Manual Steps

### Set up IAM Roles
- Create an IAM EC2 Role with the following IAM policies:
  - Select AWSGlueServiceNotebookRole 
  - Select or create inline policy to read and write to the appropriate S3 buckets

### Set up Security Groups
- Create a Security Group for the Application Load Balancer (ALB). The appropriate Source IP range should be appropriate to your environment:

Type | Protocol | Port range | Source
---- | -------- | ---------- | ------ 
HTTPS | TCP | 443 | X.X.X.X/X

  - Copy the Security Group ID: sg-XXXXXXXXXXXXXXXXX 
- Create a Security Group for the EC2 instance

Type | Protocol | Port range | Source
---- | -------- | ---------- | ------ 
HTTP | TCP | 80 | sg-XXXXXXXXXXXXXXXXX 
SSH | TCP | 22 | X.X.X.X/X

### Launch EC2 instances
- Launch M5.large or larger
- Download this git project to /home/ec2-user
- Run notebook_glue_setup.sh

```
$ cd /home/ec2-user
$ git clone https://github.com/mtwtan/glue_local_env_with_jupyter.git
$ cd glue_local_env_with_jupyter
$ chmod a+x notebook_glue_setup.sh
$ ./note_book
```

### Set up Jupyter Notebook Password
```
$ jupyter notebook password
```
### To start up Jupyter notebook
```
$ cd ~
$ source .bash_profile
$ cd ~/aws-glue-libs
$ nohup pysparkl &
```
### Set up Target Group and Application Load Balancer (ALB)
- Create a target group and register the above instance with the target group on port 80
- Create an ALB and add the following listener:
  - HTTPS (443) listener
  - Select the VPC and subnet where the above EC2 instance is placed
  - Select an appropriate SSL/TLS cert
  - Select the Security Group created above the ALB
  - Select the target group created above
  - Register the targets

### Create appropriate DNS (Optional)
- If preferred, create a DNS entry that points to the ALB DNS as a CNAME or Alias.

### Go to a Jupyter notebook
- Go to the URL for the ALB or alias
- Enter the password set above

