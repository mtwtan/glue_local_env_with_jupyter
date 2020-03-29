# Installing JupyterHub using CloudFormation Templates

## Pre-requisites
- Create or have a VPC set up that has a network set up with at least the following requirements below. Otherwise, use the Cloudformation template to set it up: [jupyterhub_vpc.yaml](https://github.com/mtwtan/glue_local_env_with_jupyter/blob/master/jupyterhub/cloudformation/jupyterhub_vpc.yaml)
  - Four (4) subnets that can route to each other:
    - Two (2) Public subnets that connects to an Internet Gateway
    - Two (2) Private subnets that can route to the Public subnets for the purpose of the Managed Active Directory; -or-
      - If you already have a working Active Directory that you have secured a network route from the public subnet above, there is no need to create the private subnets.
- Create a Managed Active Directory or have one that is accessible from the public subnets. Note: the LDAP plugin used in this JupyterHub set up does NOT work with the Simple AD or the AD connector; it only works with a Managed Active Directory or a full Windows Active Directory set up.
  - You can create it with this [CloudFormation template](https://github.com/mtwtan/glue_local_env_with_jupyter/blob/master/jupyterhub/cloudformation/jupyterhub_managed_ad.yaml) or follow the instruction in the [documentation here](https://docs.aws.amazon.com/directoryservice/latest/admin-guide/ms_ad_getting_started_create_directory.html).
- Create a Windows EC2 instance or have an existing instance that is joined to the Active Directory to manage the users that can connect to the JupyterHub set up here. To create one, here is the template to create a Windows EC2 instance: [jupyterhub_winrdp.yaml](https://github.com/mtwtan/glue_local_env_with_jupyter/blob/master/jupyterhub/cloudformation/jupyterhub_winrdp.yaml).
- Create a SSL certificate in Certificate Manager or import a SSL cert into there. Copy the ARN of the certificate to be used later for HTTPS connection
- Upload the files in [s3files](https://github.com/mtwtan/glue_local_env_with_jupyter/tree/master/jupyterhub/cloudformation/s3files) to an S3 location that will be used later in the CloudFormation template:
```
$ aws s3 cp jupyterhub_glue_setup.sh s3://<bucket name>/<folder name>/
$ aws s3 cp jupyterhub.conf s3://<bucket name>/<folder name>/
$ aws s3 cp jupyterhub.service s3://<bucket name>/<folder name>/
$ aws s3 cp kernel.json s3://<bucket name>/<folder name>/
$ aws s3 cp nginx.conf s3://<bucket name>/<folder name>/
```

## Installing via CloudFormation

- Note the IP addresses of the Active Directory servers. If you are using AWS Managed Active Directory, go to the console and copy the two (2) IP addresses here:
![AD IP address](../images/ad-directory-1.png)
- Fill out the CloudFormation form according to something like this:

![CF-ec-1](../images/ec2-cf-1.png)
![CF-ec-2](../images/ec2-cf-2.png)
![CF-ec-3](../images/ec2-cf-3.png)


### Checking to see when the userdata script is completed

```
$ cd /var/log
$ tail -f cloud-init-output.log 
Downloading from aws-glue-etl-artifacts: https://aws-glue-etl-artifacts.s3.amazonaws.com/release/org/apache/hadoop/hadoop-annotations/2.6.5/hadoop-annotations-2.6.5.pom
Downloading from central: https://repo.maven.apache.org/maven2/org/apache/hadoop/hadoop-annotations/2.6.5/hadoop-annotations-2.6.5.pom
Downloaded from central: https://repo.maven.apache.org/maven2/org/apache/hadoop/hadoop-annotations/2.6.5/hadoop-annotations-2.6.5.pom (2.4 kB at 114 kB/s)
Downloading from aws-glue-etl-artifacts: https://aws-glue-etl-artifacts.s3.amazonaws.com/release/com/google/guava/guava/11.0.2/guava-11.0.2.pom
Downloading from central: https://repo.maven.apache.org/maven2/com/google/guava/guava/11.0.2/guava-11.0.2.pom

```
```
[INFO] Copying hk2-locator-2.4.0-b34.jar to /opt/aws-glue-libs/jarsv1/hk2-locator-2.4.0-b34.jar
[INFO] Copying guice-servlet-3.0.jar to /opt/aws-glue-libs/jarsv1/guice-servlet-3.0.jar
[INFO] Copying jackson-dataformat-msgpack-0.7.0.jar to /opt/aws-glue-libs/jarsv1/jackson-dataformat-msgpack-0.7.0.jar
[INFO] Copying ion-java-1.0.2.jar to /opt/aws-glue-libs/jarsv1/ion-java-1.0.2.jar
[INFO] Copying aws-java-sdk-autoscaling-1.11.528.jar to /opt/aws-glue-libs/jarsv1/aws-java-sdk-autoscaling-1.11.528.jar
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  08:18 min
[INFO] Finished at: 2020-03-29T19:56:33Z
[INFO] ------------------------------------------------------------------------
rm: cannot remove '/opt/aws-glue-libs/conf/spark-defaults.conf': No such file or directory
/opt/aws-glue-libs
Created symlink from /etc/systemd/system/multi-user.target.wants/jupyterhub.service to /etc/systemd/system/jupyterhub.service.
Enabling: githubcommit
- Writing config: /root/.jupyter
    - Validating...
      githubcommit  OK
Installing /opt/jupyterhub/lib64/python3.7/site-packages/githubcommit/static -> githubcommit
Making directory: /usr/local/share/jupyter/nbextensions/githubcommit/
Copying: /opt/jupyterhub/lib64/python3.7/site-packages/githubcommit/static/main.js -> /usr/local/share/jupyter/nbextensions/githubcommit/main.js
- Validating: OK

    To initialize this nbextension in the browser every time the notebook (or other app) loads:
    
          jupyter nbextension enable githubcommit --py
    
Enabling notebook extension githubcommit/main...
      - Validating: OK
Created symlink from /etc/systemd/system/multi-user.target.wants/nginx.service to /usr/lib/systemd/system/nginx.service.
Connection to ec2-54-149-102-167.us-west-2.compute.amazonaws.com closed by remote host.
Connection to ec2-54-149-102-167.us-west-2.compute.amazonaws.com closed.
```

