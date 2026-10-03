#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
source ./lib.sh
wait_ssh
on_node master-node "hdfs --daemon start namenode" || true
on_node master-node "yarn --daemon start resourcemanager" || true
for w in worker-node-1 worker-node-2; do
  on_node "$w" "hdfs --daemon start datanode" || true
  on_node "$w" "yarn --daemon start nodemanager" || true
done
./forward-uis.sh
wait_datanodes 2
echo "Cluster is up."
