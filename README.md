# Hadoop + Spark Big Data Lab (GitHub Codespaces)

Hadoop 3.3.6, Spark 3.5.7, 1 master + 2 workers, Docker Compose inside a Dev Container.

## First time
```bash
chmod +x cluster/*.sh
./cluster/init-cluster.sh     # formats HDFS once, starts cluster, uploads Spark jars
./cluster/cluster-status.sh
```

## Every time the Codespace restarts
```bash
./cluster/start-cluster.sh
./cluster/cluster-status.sh
./cluster/stop-cluster.sh     # when finished
```

## MapReduce WordCount
```bash
cd practicals/mapreduce
javac -classpath "$(hadoop classpath)" -d . WordCount.java
jar -cvf WordCount.jar WordCount*.class
hdfs dfs -mkdir -p /lab/wordcount/input
hdfs dfs -put -f input.txt /lab/wordcount/input/
hdfs dfs -rm -r -f /lab/wordcount/output
hadoop jar WordCount.jar WordCount /lab/wordcount/input /lab/wordcount/output
hdfs dfs -cat /lab/wordcount/output/part-r-00000
```

## Spark on YARN (run the MapReduce input step above first)
```bash
spark-submit --master yarn --deploy-mode client practicals/spark/wordcount.py
```

## Web UIs
Ports panel: 9870 (NameNode), 8088 (YARN), 4040 (Spark, only while a job runs).

## Verification
```bash
hdfs dfsadmin -report | grep "Live datanodes"      # expect (2)
yarn node -list                                    # expect 2 RUNNING
echo "hello hadoop hello spark" > /tmp/test.txt
hdfs dfs -put -f /tmp/test.txt /user/raunak/test.txt
hdfs fsck /user/raunak/test.txt -files -blocks -locations   # expect repl=2
```

Note: changes under config/ need "Codespaces: Rebuild Container".
Root/password SSH is for this isolated lab network only.
