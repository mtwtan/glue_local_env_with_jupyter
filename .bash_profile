PATH=$PATH:/home/ec2-user/apache-maven-3.6.0/bin
export SPARK_HOME=/home/ec2-user/bin/spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8/
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.242.b08-0.amzn2.0.1.x86_64/jre
export PATH=$PATH:$JAVA_HOME/bin

alias python=python3

export SPARK_CONF_DIR=$HOME/aws-glue-libs/conf
export PYTHONPATH="${SPARK_HOME}python/:${SPARK_HOME}python/lib/py4j-0.10.7-src.zip:$HOME/bin/aws-glue-libs/PyGlue.zip:${PYTHONPATH}"

export PYSPARK_DRIVER_PYTHON="jupyter"
export PYSPARK_DRIVER_PYTHON_OPTS="notebook"
export PYSPARK_PYTHON=python3
export PATH=${SPARK_HOME}bin:$PATH:~/.local/bin:$JAVA_HOME/bin:$JAVA_HOME/jre/bin
