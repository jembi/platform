#!/bin/bash

if [[ $# -eq 0 ]]; then
    echo "Usage: ./prune-volumes.sh <hosts...>"
    exit 1
fi

for host in "$@"; do
    echo "Removing unused volumes on node: ${host}..."
    ssh ubuntu@"${host}" 'docker volume prune -f'
    echo "Done."
done
