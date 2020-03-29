#!/bin/bash

cd $HOME
echo $# arguments 
if [ "$#" -lt 7 ]; then
    echo "Please make sure you provide 6 parameters: 2 DNS server IPs, ad domain name, ldap bind user, bind user password, download location";
    exit 1
fi
dns1=${1}
dns2=${2}
addomain=${3}
ldapbinduser=${4}
ldapbinduserpw=${5}
ldapou=${6}
gitclonedir=${7}

sudo sh -c "echo \"supersede domain-name-servers ${dns1}, ${dns2};\" >> /etc/dhcp/dhclient.conf"

# Install packages
sudo yum -y install java-1.8.0-openjdk.x86_64 java-1.8.0-openjdk-devel git gcc python3 python3-devel
sudo amazon-linux-extras install nginx1.12 -y

# Set python3 as default python language
echo "alias python=python3" >> $HOME/.bash_profile
sudo sh -c 'echo "alias python=python3" >> /root/.bash_profile'
source $HOME/.bash_profile

# Install nodejs and nvm
cd gitclonedir
sudo yum install -y gcc-c++ make
curl -sL https://rpm.nodesource.com/setup_13.x | sudo -E bash -
sudo yum -y install nodejs nodejs-devel
sudo sh -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash'

## Test if nodejs is running
# node -e "console.log('Running Node.js ' + process.version)"

# configurable-http-proxy
sudo npm install -g configurable-http-proxy

# Create virtual python environment
sudo python3 -m venv /opt/jupyterhub/

# Install Jupyter
sudo /opt/jupyterhub/bin/python3 -m pip install wheel
sudo /opt/jupyterhub/bin/python3 -m pip install jupyterhub jupyterlab
sudo /opt/jupyterhub/bin/python3 -m pip install ipywidgets
sudo /opt/jupyterhub/bin/python3 -m pip install jupyterhub-ldapauthenticator
sudo /opt/jupyterhub/bin/python3 -m pip install git+https://github.com/sat28/githubcommit.git
sudo /opt/jupyterhub/bin/python3 -m pip install requests

# Create configuration for JupyterHub
sudo mkdir -p /opt/jupyterhub/etc/jupyterhub/
cd /opt/jupyterhub/etc/jupyterhub/

# Generate Jupyter configuration file
sudo /opt/jupyterhub/bin/jupyterhub --generate-config
sudo sh -c 'echo "c.Spawner.default_url = \"/lab\"" >> /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py'
#sudo sh -c 'echo "c.JupyterHub.bind_url = \"http://:8000/jupyter\"" >> /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py'
#sudo sh -c 'echo "c.JupyterHub.authenticator_class = \"ldapauthenticator.LDAPAuthenticator\"" >> /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py'

## Active Directory integration
sudo sh -c 'echo "c.JupyterHub.authenticator_class = \"ldapauthenticator.LDAPAuthenticator\"" >> /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py'
sudo sh -c "echo \"c.LDAPAuthenticator.server_address = 'ldap://${addomain}'\" >> /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py"
sudo sh -c 'echo "c.LDAPAuthenticator.lookup_dn = True" >> /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py'
sudo sh -c 'echo "c.LDAPAuthenticator.lookup_dn_search_filter = \"({login_attr}={login})\"" >> /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py'
sudo sh -c "echo \"c.LDAPAuthenticator.lookup_dn_search_user = '${ldapbinduser}'\" >> /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py"
sudo sh -c "echo \"c.LDAPAuthenticator.lookup_dn_search_password = '${ldapbinduserpw}'\" >> /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py"
sudo sh -c 'echo "c.LDAPAuthenticator.use_lookup_dn_username = False" >> /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py'
sudo sh -c "echo \"c.LDAPAuthenticator.user_search_base = '${ldapou}'\" >> /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py"
sudo sh -c 'echo "c.LDAPAuthenticator.user_attribute = \"sAMAccountName\"" >> /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py'
sudo sh -c 'echo "c.LDAPAuthenticator.lookup_dn_user_dn_attribute = \"cn\"" >> /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py'
sudo sh -c 'echo "c.LDAPAuthenticator.escape_userdn = False" >> /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py'
sudo sh -c 'echo "c.LDAPAuthenticator.bind_dn_template = \"{username}\"" >> /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py'
sudo sh -c 'echo "c.JupyterHub.extra_log_file = \"/var/log/jupyterhub.log\"" >> /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py'

# Install Spark and Glue components

# Download glue library and set to version glue-1.0

cd /opt
sudo git clone https://github.com/awslabs/aws-glue-libs.git
cd /opt/aws-glue-libs
sudo git checkout glue-1.0

# Download Maven
cd /opt
sudo curl -o apache-maven-3.6.0-bin.tar.gz https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-common/apache-maven-3.6.0-bin.tar.gz
sudo tar -xvf apache-maven-3.6.0-bin.tar.gz

# Download Spark Hadoop files
sudo curl -o spark-2.4.3-bin-hadoop2.8.tgz https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-1.0/spark-2.4.3-bin-hadoop2.8.tgz
sudo tar -xvf spark-2.4.3-bin-hadoop2.8.tgz

# Backup original $HOME/.bash_profile
cp $HOME/.bash_profile $HOME/.bash_profile_bak
sudo sh -c 'cp /root/.bash_profile /root/.bash_profile_bak'

#### Configure $HOME/.bash_profile to set the appropriate environmental variables

# Add maven to PATH
echo "export PATH=\$PATH:/opt/apache-maven-3.6.0/bin" >> $HOME/.bash_profile
sudo sh -c 'echo "export PATH=\$PATH:/opt/apache-maven-3.6.0/bin" >> /root/.bash_profile'

# Set SPARK_HOME
echo "export SPARK_HOME=/opt/spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8" >> $HOME/.bash_profile
sudo sh -c 'echo "export SPARK_HOME=/opt/spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8" >> /root/.bash_profile'

## Get the new env variables
source $HOME/.bash_profile

# Set JAVA_HOME
####java=$(alternatives --display java | grep "link currently points to")
java=$(alternatives --display java | grep link | sed 's/^ link.*to //')
java2=$(echo $java | sed 's/link currently points to //')
jvmhome=$(echo $java2 | sed 's/\/bin\/java//')
echo "export JAVA_HOME=$jvmhome" >> $HOME/.bash_profile
sudo sh -c 'export JAVA_HOME=$jvmhome" >> /root/.bash_profile'
## Get the new env variables
source $HOME/.bash_profile

# Configuration setting for PYSPARK
echo "export SPARK_CONF_DIR=/opt/aws-glue-libs/conf" >> $HOME/.bash_profile
echo "export PYTHONPATH=\"${SPARK_HOME}/python/:${SPARK_HOME}/python/lib/py4j-0.10.7-src.zip:/opt/aws-glue-libs/PyGlue.zip:${PYTHONPATH}\"" >> $HOME/.bash_profile

echo "export PYSPARK_DRIVER_PYTHON=\"jupyterhub\"" >> $HOME/.bash_profile
echo "export PYSPARK_DRIVER_PYTHON_OPTS=\"-f /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py\"" >> $HOME/.bash_profile
echo "export PYSPARK_PYTHON=python3" >> $HOME/.bash_profile
echo "export PATH=${SPARK_HOME}/bin:$PATH:/opt/jupyterhub/bin:$JAVA_HOME/bin:$JAVA_HOME/jre/bin" >> $HOME/.bash_profile

# Pull in the new environment settings
source $HOME/.bash_profile

# Setup Glue Libraries and modify glue setup file
cd /opt/aws-glue-libs
sudo chmod a+x ./bin/glue-setup.sh
sudo env PATH=$PATH ./bin/glue-setup.sh
## Modify the glue-setup to stop downloading jar files
sudo sed -i "s/mvn -f/#mvn -f/" ./bin/glue-setup.sh 

# Remove wrong version of netty-all-*.jar
sudo rm -f /opt/aws-glue-libs/jarsv1/netty-all-4.0.23.Final.jar
sudo cp $SPARK_HOME/jars/netty-all-4.1.17.Final.jar /opt/aws-glue-libs/jarsv1
# Remove an additional javax.servlet that cause dependency problem
sudo rm -f /opt/aws-glue-libs/jarsv1/javax.servlet-3.0.0.v201112011016.jar

# Create Glue PySpark kernel
sudo mkdir -p /opt/jupyterhub/share/jupyter/kernels/gluepyspark
sudo cp $gitclonedir/kernel.json /opt/jupyterhub/share/jupyter/kernels/gluepyspark

# Create Jupyter Hub systemd service

sudo cp $gitclonedir/jupyterhub.service /etc/systemd/system/jupyterhub.service
sudo systemctl daemon-reload
sudo systemctl enable jupyterhub.service
sudo systemctl start jupyterhub.service

sudo /opt/jupyterhub/bin/jupyter serverextension enable --py githubcommit
sudo /opt/jupyterhub/bin/jupyter nbextension install --py githubcommit
sudo /opt/jupyterhub/bin/jupyter nbextension enable --py githubcommit

# Modify NGINX configuration
sudo sh -c 'mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig'
sudo sh -c "cp $gitclonedir/nginx.conf /etc/nginx/nginx.conf"
sudo sh -c "cp $gitclonedir/jupyterhub.conf /etc/nginx/conf.d/jupyterhub.conf"
sudo sh -c 'systemctl enable nginx.service'

sudo reboot now
