#!/bin/bash
cd "$(dirname "$0")"
source ./lib.sh
for h in $NODES; do
  echo "== $h"; on_node "$h" "jps | grep -v Jps"
done
echo; echo "== HDFS"; hdfs dfsadmin -report | head -n 20
echo; echo "== YARN"; yarn node -list
