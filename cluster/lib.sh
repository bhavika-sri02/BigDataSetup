#!/bin/bash
export SSHPASS=hadoop
NODES="master-node worker-node-1 worker-node-2"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
SSH_OPTS="$SSH_OPTS -o LogLevel=ERROR -o ConnectTimeout=5"

# on_node HOST "command" -> runs the command on HOST as root in a login shell
on_node() { local h="$1"; shift; sshpass -e ssh $SSH_OPTS "root@$h" "bash -lc '$*'"; }

wait_ssh() {
  for h in $NODES; do
    until sshpass -e ssh $SSH_OPTS "root@$h" true 2>/dev/null; do
      echo "waiting for sshd on $h"; sleep 2
    done
  done
}

wait_datanodes() {
  echo "waiting for $1 live DataNodes..."
  until hdfs dfsadmin -report 2>/dev/null | grep -q "Live datanodes ($1)"; do sleep 3; done
}
