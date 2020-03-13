# Creating a Jupyter Notebook environment for running AWS Glue ETL scripts locally on an AWS EC2 Instance
A local development environment to run AWS Glue ETL scripts with a Jupyter Notebook server and made available over https.

## Pre-requisites
- This setup assumes that users are using AWS
- An available VPC with a subnet that is available over the public internet with an Internet Gateway.

## WORK IN PROGRESS
### CloudFormation template in progress

## Manual Steps

### Set up IAM Roles
- Create an IAM Role with the following IAM policies:


### Set up Security Groups

### Set up 

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
