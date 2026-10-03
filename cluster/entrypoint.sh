#!/bin/bash
set -e
mkdir -p /run/sshd
ssh-keygen -A
echo "Node started: $(hostname)"
exec /usr/sbin/sshd -D -e
