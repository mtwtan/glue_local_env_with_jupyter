# Creating a JupyterHub environment for running AWS Glue ETL scripts locally on an AWS EC2 Instance or on a Docker Container
A local development environment to run AWS Glue ETL scripts with a JupyterHub server and made available over https.

## Running on an EC2 Instance

### Pre-requisites
- This setup assumes that users are using AWS
- An available VPC with a subnet that is available over the public internet with an Internet Gateway.
- Have an available and appropriate SSL/TLS cert
- Assumes you are running Active Directory on AWS and all network routing and firewall settings are configured to allow network traffic routing to the Active Directory IP addresses
- Assumes that you have the user accounts set up on Active Directory and that the following has been set up:
  - OU of the AD where the user will be searched. Example: ou=users,dc=example,dc=com
  - Username and password of a user that has been delegated to search the directory and be able to authenticate user
  - The Active Directory has been set up also as a DNS server that can forward DNS queries to the other DNS servers on the Internet -- The AD DNS servers will replace the DNS entries in the DHCP settings of the EC2 instance.

### WORK IN PROGRESS
#### CloudFormation template in progress

### Manual Steps

#### Set up IAM Roles
- Create an IAM EC2 Role with the following IAM policies:
  - Select AWSGlueServiceNotebookRole 
  - Select or create inline policy to read and write to the appropriate S3 buckets

#### Set up Security Groups
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

#### Launch EC2 instances
- Launch M5.large or larger
- Download this git project to /home/ec2-user
- Install git and clone repository to $HOME directory

```
$ yum -y install git
$ cd /home/ec2-user
$ git clone https://github.com/mtwtan/glue_local_env_with_jupyter.git
```

- Run jupyterhub_glue_setup.sh <DNS1> <DNS2> <ldapuser> <ldapuser password>
  - DNS1: IP address of one of the Active Directory (AD) servers
  - DNS2: IP address of the second AD server

```
$ cd glue_local_env_with_jupyter/jupyterhub
$ sudo -c 'bash jupyterhub_glue_setup.sh'
```
*The EC2 instance will reboot at the end of the installation to allow the DHCP to pick up the new DNS servers*

#### Set up Jupyter Notebook Password
```
$ jupyter notebook password
```
#### To start up Jupyter notebook
```
$ cd ~
$ source .bash_profile
$ cd ~/aws-glue-libs
$ nohup pysparkl &
```
#### Set up Target Group and Application Load Balancer (ALB)
- Create a target group and register the above instance with the target group on port 80
- Create an ALB and add the following listener:
  - HTTPS (443) listener
  - Select the VPC and subnet where the above EC2 instance is placed
  - Select an appropriate SSL/TLS cert
  - Select the Security Group created above the ALB
  - Select the target group created above
  - Register the targets

#### Create appropriate DNS (Optional)
- If preferred, create a DNS entry that points to the ALB DNS as a CNAME or Alias.

#### Go to a Jupyter notebook
- Go to the URL for the ALB or alias
- Enter the password set above

## Running on a local Docker Container

### Running on your local Docker Swarm on your desktop or laptop

#### Pre-requisites
- Have an AWS account with access keys and passwords created in an .aws folder
- Installed Docker Desktop on your desktop/laptop

#### Steps
- Clone the repository
- Build the docker image or download from Docker Hub
- Run the docker container with the specifications as listed below

##### Build your own docker image
```
$ git clone https://github.com/mtwtan/glue_local_env_with_jupyter.git
$ ls -l   ## Verify that you have the Dockerfile
```
##### (option 1) Build your own docker image
```
$ docker build -t <repository>/<image name>:<tag> .   ## Note the period at the end of the command
###  Docker build will take quite a long time. This image is quite big.
```
##### (option 2) Pull from Docker Hub
```
$ docker pull matthewtan/jupyterglue:latest
```
##### Run the docker image
```
$ docker run -v <folder location of your AWS credentials>/.aws:/home/glue/.aws -v <folder location of your python notebook files>:/home/glue/notebook -p 8000:8000 --rm -it <repository>/<image name>:<tag>

### Example

$ docker run -v ~/glue/.aws:/home/glue/.aws -v ~/glue_notebooks:/home/glue/notebook -p 8000:8000 --rm -it matthewtan/jupyterglue:latest

[glue@864f6dac7803 ~]$ pwd 
/home/glue
[glue@864f6dac7803 ~]$ cd notebook
[glue@864f6dac7803 notebook]$ pyspark
[I 22:13:11.965 NotebookApp] Writing notebook server cookie secret to /home/glue/.local/share/jupyter/runtime/notebook_cookie_secret
[W 22:13:12.431 NotebookApp] WARNING: The notebook server is listening on all IP addresses and not using encryption. This is not recommended.
[I 22:13:12.643 NotebookApp] Serving notebooks from local directory: /home/glue/notebook
[I 22:13:12.644 NotebookApp] The Jupyter Notebook is running at:
[I 22:13:12.644 NotebookApp] http://864f6dac7803:8000/?token=3fdf9f5e058a32ef3c1e382424ccb492dc9c641dd00c654a
[I 22:13:12.644 NotebookApp]  or http://127.0.0.1:8000/?token=3fdf9f5e058a32ef3c1e382424ccb492dc9c641dd00c654a
[I 22:13:12.644 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
[W 22:13:12.654 NotebookApp] No web browser found: could not locate runnable browser.
[C 22:13:12.655 NotebookApp] 
    
    To access the notebook, open this file in a browser:
        file:///home/glue/.local/share/jupyter/runtime/nbserver-19-open.html
    Or copy and paste one of these URLs:
        http://864f6dac7803:8000/?token=3fdf9f5e058a32ef3c1e382424ccb492dc9c641dd00c654a
     or http://127.0.0.1:8000/?token=3fdf9f5e058a32ef3c1e382424ccb492dc9c641dd00c654a
```

### Running on Amazon ECS or EKS

#### Work in progress
