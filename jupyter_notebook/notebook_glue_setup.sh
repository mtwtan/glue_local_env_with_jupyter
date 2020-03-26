# Install packages
sudo yum -y install java-1.8.0-openjdk.x86_64 java-1.8.0-openjdk-devel git gcc python3 python3-devel
sudo amazon-linux-extras install nginx1.12 -y

cd $HOME

# Download glue library and set to version glue-1.0
git clone https://github.com/awslabs/aws-glue-libs.git
cd aws-glue-libs/
git checkout glue-1.0

# Download Maven
cd $HOME
curl -o apache-maven-3.6.0-bin.tar.gz https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-common/apache-maven-3.6.0-bin.tar.gz
tar -xvf apache-maven-3.6.0-bin.tar.gz

# Download Spark Hadoop files
curl -o spark-2.4.3-bin-hadoop2.8.tgz https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-1.0/spark-2.4.3-bin-hadoop2.8.tgz
tar -xvf spark-2.4.3-bin-hadoop2.8.tgz

# Backup original $HOME/.bash_profile
cp $HOME/.bash_profile $HOME/.bash_profile_bak

#### Configure $HOME/.bash_profile to set the appropriate environmental variables

# Add maven to PATH
echo "export PATH=\$PATH:$HOME/apache-maven-3.6.0/bin" >> $HOME/.bash_profile

# Set SPARK_HOME
echo "export SPARK_HOME=$HOME/spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8" >> $HOME/.bash_profile

## Get the new env variables
source $HOME/.bash_profile

# Set JAVA_HOME
####java=$(alternatives --display java | grep "link currently points to")
java=$(alternatives --display java | grep link | sed 's/^ link.*to //')
java2=$(echo $java | sed 's/link currently points to //')
jvmhome=$(echo $java2 | sed 's/\/bin\/java//')
echo "export JAVA_HOME=$jvmhome" >> $HOME/.bash_profile

## Get the new env variables
source $HOME/.bash_profile

# Set python3 as default python language
echo "alias python=python3" >> $HOME/.bash_profile

# Configuration setting for PYSPARK
echo "export SPARK_CONF_DIR=$HOME/aws-glue-libs/conf" >> $HOME/.bash_profile
echo "export PYTHONPATH=\"${SPARK_HOME}/python/:${SPARK_HOME}/python/lib/py4j-0.10.7-src.zip:$HOME/aws-glue-libs/PyGlue.zip\"" >> $HOME/.bash_profile

echo "export PYSPARK_DRIVER_PYTHON=\"jupyter\"" >> $HOME/.bash_profile
echo "export PYSPARK_DRIVER_PYTHON_OPTS=\"notebook\"" >> $HOME/.bash_profile
echo "export PYSPARK_PYTHON=python3" >> $HOME/.bash_profile
echo "export PATH=${SPARK_HOME}/bin:$PATH:~/.local/bin:$JAVA_HOME/bin:$JAVA_HOME/jre/bin" >> $HOME/.bash_profile

# Pull in the new environment settings
source $HOME/.bash_profile

# Setup Glue Libraries and modify glue setup file
cd $HOME/aws-glue-libs
chmod a+x ./bin/glue-setup.sh
./bin/glue-setup.sh
## Modify the glue-setup to stop downloading jar files
sed -i "s/mvn -f/#mvn -f/" ./bin/glue-setup.sh 

# Remove wrong version of netty-all-*.jar
rm $HOME/aws-glue-libs/jarsv1/netty-all-4.0.23.Final.jar
cp $SPARK_HOME/jars/netty-all-4.1.17.Final.jar $HOME/aws-glue-libs/jarsv1
# Remove an additional javax.servlet that cause dependency problem
rm $HOME/aws-glue-libs/jarsv1/javax.servlet-3.0.0.v201112011016.jar

# Upgrade pip
sudo pip3 install pip --upgrade

# Install jupyter
cd $HOME
pip install jupyter
pip install git+https://github.com/sat28/githubcommit.git
pip install requests
jupyter serverextension enable --py githubcommit
jupyter nbextension install --py githubcommit --user
jupyter nbextension enable --py githubcommit
jupyter notebook --generate-config

# Add Jupyter configuration
echo "c.NotebookApp.allow_remote_access = True" >> $HOME/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.port = 8000" >> $HOME/.jupyter/jupyter_notebook_config.py

# Modify NGINX configuration
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig
sudo cp ~/glue_local_env_with_jupyter/common/nginx.conf /etc/nginx/nginx.conf
sudo cp ~/glue_local_env_with_jupyter/common/notebook.conf /etc/nginx/conf.d/notebook.conf
sudo systemctl enable nginx.service
sudo systemctl start nginx.service

cd $HOME
source .bash_profile
