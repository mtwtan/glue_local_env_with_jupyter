FROM amazoncorretto:latest

RUN yum install -y git python3 wget tar zip pandoc which gcc python3-devel

RUN adduser glue -d /home/glue -s /bin/bash -m \
    && chown -R glue:glue /home/glue

ENV glue_spark_url https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-1.0/spark-2.4.3-bin-hadoop2.8.tgz

ENV spark_zip spark-2.4.3-bin-hadoop2.8.tgz

ENV maven_URL https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-common/apache-maven-3.6.0-bin.tar.gz

ENV maven_ZIP apache-maven-3.6.0-bin.tar.gz

ENV glue_repo https://github.com/awslabs/aws-glue-libs

ENV maven_path /usr/local/share/applications/apache-maven-3.6.0/bin

ENV spark_path /usr/local/share/applications/spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8/bin

ENV glue_lib /usr/local/share/applications/aws-glue-libs

ENV glue_bin /usr/local/share/applications/aws-glue-libs/bin

ENV SPARK_HOME /usr/local/share/applications/spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8

ENV SPARK_CONF_DIR /usr/local/share/applications/aws-glue-libs/conf

ENV GLUE_JARS_DIR $glue_lib/jars

ENV PATH $maven_path:$spark_path:$glue_bin:$PATH

ENV PYTHONPATH="$SPARK_HOME/python/:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip:$glue_lib/PyGlue.zip"

ENV PYSPARK_DRIVER_PYTHON jupyter

ENV PYSPARK_DRIVER_PYTHON_OPTS notebook

ENV PYSPARK_PYTHON python3

ENV PYTHONPATH $SPARK_HOME/python/:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip:$glue_lib/PyGlue.zip:$PYTHONPATH

WORKDIR /usr/local/share/applications

RUN wget $maven_URL \
    && tar -xzf $maven_ZIP \
    && rm -f apache-maven-3.6.0-bin.tar.gz 

RUN wget $glue_spark_url \
    && tar -xzf $spark_zip \
    && rm -f spark-2.4.3-bin-hadoop2.8.tgz

RUN git clone $glue_repo \
    && cd aws-glue-libs \
    && git checkout glue-1.0

RUN cd $glue_bin \
    && sh glue-setup.sh \
    && sed -e '/mvn/ s/^#*/#/' -i glue-setup.sh

RUN rm -rf aws-glue-libs/jarsv1/netty-all-4.0.23.Final.jar \
    && cp spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8/jars/netty-all-4.1.17.Final.jar aws-glue-libs/jarsv1/ \
    && rm aws-glue-libs/jarsv1/javax.servlet-3.0.0.v201112011016.jar

RUN chown -R glue:glue /usr/local/share/applications \
    && chown -R glue:glue /usr/local/lib \
    && chown -R glue:glue /usr/local/bin \
    && chown -R glue:glue /usr/local/share

USER glue 

WORKDIR /home/glue

ENV HOME /home/glue
ENV PYTHONPATH $SPARK_HOME/python/:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip:$glue_lib/PyGlue.zip:$PYTHONPATH
ENV PATH="$PATH:$HOME/.local/bin:$HOME/bin"

RUN pip3 install jupyter --user \
    && pip3 install git+https://github.com/sat28/githubcommit.git --user \
    && pip3 install requests --user \
    && pip3 install pytest --user \
    && pip3 install awscli --upgrade --user \
    && jupyter serverextension enable --py githubcommit --user \
    && jupyter nbextension install --py githubcommit --user \
    && jupyter nbextension enable --py githubcommit --user \
    && jupyter notebook --generate-config \
    && mkdir -p /home/glue/notebook \
    && mkdir -p /home/glue/.local/share/jupyter/kernels/gluepyspark

    # Add Jupyter configuration
RUN echo "c.NotebookApp.allow_remote_access = True" >> /home/glue/.jupyter/jupyter_notebook_config.py \
    && echo "c.NotebookApp.port = 8000" >> /home/glue/.jupyter/jupyter_notebook_config.py \
    && echo "c.NotebookApp.ip = '*'" >> /home/glue/.jupyter/jupyter_notebook_config.py

USER glue

WORKDIR /home/glue

