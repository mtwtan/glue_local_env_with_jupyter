# Installing JupyterHub using CloudFormation Templates

## Pre-requisites
- Create or have a VPC set up that has a network set up with at least the following requirements below. Otherwise, use the Cloudformation template to set it up: [jupyterhub_vpc.yaml](https://github.com/mtwtan/glue_local_env_with_jupyter/blob/master/jupyterhub/cloudformation/jupyterhub_vpc.yaml)
  - Four (4) subnets that can route to each other:
    - Two (2) Public subnets that connects to an Internet Gateway
    - Two (2) Private subnets that can route to the Public subnets for the purpose of the Managed Active Directory; -or-
      - If you already have a working Active Directory that you have secured a network route from the public subnet above, there is no need to create the private subnets.
- Create a Managed Active Directory or have one that is accessible from the public subnets. Note: the LDAP plugin used in this JupyterHub set up does NOT work with the Simple AD or the AD connector; it only works with a Managed Active Directory or a full Windows Active Directory set up.
- Create a Windows EC2 instance or have an existing instance that is joined to the Active Directory to manage the users that can connect to the JupyterHub set up here. To create one, here is the template to create a Windows EC2 instance: [jupyterhub_winrdp.yaml](https://github.com/mtwtan/glue_local_env_with_jupyter/blob/master/jupyterhub/cloudformation/jupyterhub_winrdp.yaml).
