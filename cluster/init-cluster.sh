#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
source ./lib.sh
wait_ssh
if on_node master-node "test -d /opt/hadoop/data/namenode/current"; then
  echo "NameNode already formatted - skipping format."
else
  on_node master-node "hdfs namenode -format -force"
fi
./start-cluster.sh
hdfs dfsadmin -safemode wait
hdfs dfs -mkdir -p /user/raunak /tmp /spark-jars
hdfs dfs -chmod 1777 /tmp
hdfs dfs -chown raunak:supergroup /user/raunak
# Upload Spark jars once so spark-submit does not re-upload them every time
if ! hdfs dfs -test -e /spark-jars/.uploaded; then
  hdfs dfs -put -f "$SPARK_HOME"/jars/*.jar /spark-jars/
  hdfs dfs -touchz /spark-jars/.uploaded
fi
echo "Init complete."
