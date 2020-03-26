# Creating a Jupyter based interactive environment for running AWS Glue ETL scripts
A local development environment to run AWS Glue ETL scripts with a Jupyter Notebook server and made available over https. At this time, the kernel provided here is PySpark with [AWS Glue ETL Library(https://docs.aws.amazon.com/glue/latest/dg/aws-glue-programming-etl-libraries.html) embedded. 

## Running a Jupyter Notebook on a local desktop/laptop or an EC2 instaance
- This installation script allows you to run a setup on your desktop/laptop using Docker Desktop or to be installed on an AWS EC2 instance that can be accessed over https handled by an Application Load Balancer (ALB):
  - [Link to Jupyter Notebook install scripts](https://github.com/mtwtan/glue_local_env_with_jupyter/tree/master/jupyter_notebook)

## Running a JupyterHub environment on an EC2 instance
- This installation script allows you to run a [JupyterHub](https://jupyter.org/hub) environment in an EC2 instance over https handled by an Application Load Balancer. The setup provides authentication using Active Directory and allows several users to have their own workspace and home directory.
  - [Link to JupyterHub install scripts](https://github.com/mtwtan/glue_local_env_with_jupyter/tree/master/jupyterhub)

