#!/bin/bash
# Relay the master's web UIs into this container so Codespaces can forward them.
for spec in 9870:master-node:9870 8088:master-node:8088; do
  IFS=: read -r lport host rport <<< "$spec"
  if ! pgrep -f "TCP-LISTEN:${lport}," > /dev/null; then
    nohup socat TCP-LISTEN:${lport},fork,reuseaddr TCP:${host}:${rport} > /dev/null 2>&1 &
  fi
done
