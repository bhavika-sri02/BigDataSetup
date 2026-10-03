FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-11-jdk-headless python3 python3-pip wget curl ca-certificates \
    openssh-server openssh-client sshpass socat iputils-ping net-tools procps \
    vim nano git sudo \
    && rm -rf /var/lib/apt/lists/*

# Non-root user for the Dev Container (Ubuntu 24.04 ships a default 'ubuntu' user with UID 1000)
RUN userdel -r ubuntu 2>/dev/null || true \
    && useradd -m -s /bin/bash -u 1000 vscode \
    && echo 'vscode ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vscode

RUN wget -q -O /tmp/h.tgz \
      https://archive.apache.org/dist/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz \
    && tar -xzf /tmp/h.tgz -C /opt && mv /opt/hadoop-3.3.6 /opt/hadoop && rm /tmp/h.tgz

RUN wget -q -O /tmp/s.tgz \
      https://archive.apache.org/dist/spark/spark-3.5.7/spark-3.5.7-bin-hadoop3.tgz \
    && tar -xzf /tmp/s.tgz -C /opt && mv /opt/spark-3.5.7-bin-hadoop3 /opt/spark && rm /tmp/s.tgz

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 \
    HADOOP_HOME=/opt/hadoop \
    HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop \
    YARN_CONF_DIR=/opt/hadoop/etc/hadoop \
    SPARK_HOME=/opt/spark \
    PYSPARK_PYTHON=python3 \
    HADOOP_USER_NAME=root \
    PYTHONPATH=/opt/spark/python:/opt/spark/python/lib/py4j-0.10.9.7-src.zip
ENV PATH=${PATH}:/opt/hadoop/bin:/opt/hadoop/sbin:/opt/spark/bin:/opt/spark/sbin

# Same environment for login shells (SSH commands use: bash -lc "...")
RUN { for v in JAVA_HOME HADOOP_HOME HADOOP_CONF_DIR YARN_CONF_DIR SPARK_HOME \
        PYSPARK_PYTHON HADOOP_USER_NAME PYTHONPATH PATH; do \
        echo "export $v=\"$(printenv $v)\""; done; } > /etc/profile.d/hadoop.sh

# Configuration
COPY config/core-site.xml config/hdfs-site.xml config/yarn-site.xml config/mapred-site.xml \
     config/workers config/hadoop-env.sh /opt/hadoop/etc/hadoop/
COPY config/spark-defaults.conf /opt/spark/conf/spark-defaults.conf

# Data / log dirs (logs writable by the vscode user for client-side commands)
RUN mkdir -p /opt/hadoop/data/namenode /opt/hadoop/data/datanode /opt/hadoop/logs /opt/cluster \
    && chmod -R a+rwX /opt/hadoop/logs

# SSH for the internal lab network only (never publish port 22)
RUN echo 'root:hadoop' | chpasswd \
    && printf 'PermitRootLogin yes\nPasswordAuthentication yes\n' > /etc/ssh/sshd_config.d/10-lab.conf \
    && sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@' /etc/pam.d/sshd \
    && mkdir -p /run/sshd

COPY cluster/entrypoint.sh /opt/cluster/entrypoint.sh
RUN chmod +x /opt/cluster/entrypoint.sh

EXPOSE 9870 8088 9864 8042
CMD ["/opt/cluster/entrypoint.sh"]
