# Install packages
sudo yum -y install java-1.8.0-openjdk.x86_64 git gcc python3 python3-devel nginx

cd ~

# Download glue library and set to version glue-1.0
git clone https://github.com/awslabs/aws-glue-libs.git
cd aws-glue-libs/
git checkout glue-1.0

# Download Maven
cd ~
curl -o apache-maven-3.6.0-bin.tar.gz https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-common/apache-maven-3.6.0-bin.tar.gz
tar -xvf apache-maven-3.6.0-bin.tar.gz

# Download Spark Hadoop files
curl -o spark-2.4.3-bin-hadoop2.8.tgz https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-1.0/spark-2.4.3-bin-hadoop2.8.tgz
tar -xvf spark-2.4.3-bin-hadoop2.8.tgz

# Backup original .bash_profile
cp .bash_profile .bash_profile_bak

#### Configure .bash_profile to set the appropriate environmental variables

# Add maven to PATH
echo "PATH=\$PATH:/home/ec2-user/apache-maven-3.6.0/bin" >> .bash_profile

# Set SPARK_HOME
echo "export SPARK_HOME=/home/$USER/spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8" >> .bash_profile

# Set JAVA_HOME
####java=$(alternatives --display java | grep "link currently points to")
java=$(alternatives --display java | grep link | sed 's/^ link.*to //')
java2=$(echo $java | sed 's/link currently points to //')
jvmhome=$(echo $java2 | sed 's/\/bin\/java//')
echo "export JAVA_HOME=$jvmhome" >> .bash_profile

# Set python3 as default python language
echo "alias python=python3" >> .bash_profile


source .bash_profile


# Upgrade pip
sudo pip3 install pip --upgrade

# Install jupyter
cd ~
pip install jupyter
pip install git+https://github.com/sat28/githubcommit.git
pip install requests
jupyter serverextension enable --py githubcommit
jupyter nbextension install --py githubcommit --user
jupyter nbextension enable --py githubcommit

# Modify NGINX configuration
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig
sudo cp ~/glue_local_env_with_jupyter/nginx.conf /etc/nginx/nginx.conf
sudo cp ~/glue_local_env_with_jupyter/notebook.conf /etc/nginx/conf.d/notebook.conf
sudo systemctl enable nginx.service
sudo systemctl start nginx.service
