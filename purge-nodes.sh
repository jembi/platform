#!/bin/bash

if [[ $# -eq 0 ]]; then
  echo "Usage: ./purge-nodes.sh <hosts...>"
  exit 1
fi

for host in "$@"; do
  echo "Purging node: ${host}..."
  ssh ubuntu@"${host}" 'docker service rm $(docker service ls -q) ; docker rm -f $(docker ps -aq) ; docker volume prune -f ; docker config rm $(docker config ls -q)'
  echo "Done."
done
