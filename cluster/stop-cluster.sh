#!/bin/bash
set -uo pipefail
cd "$(dirname "$0")"
source ./lib.sh
for w in worker-node-1 worker-node-2; do
  on_node "$w" "yarn --daemon stop nodemanager" || true
  on_node "$w" "hdfs --daemon stop datanode" || true
done
on_node master-node "yarn --daemon stop resourcemanager" || true
on_node master-node "hdfs --daemon stop namenode" || true
echo "Cluster stopped."
