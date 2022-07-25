#!/bin/bash

if [[ $# -eq 0 ]]; then
    echo "Usage: ./prune-containers.sh <hosts...>"
    exit 1
fi

for host in "$@"; do
    echo "Removing dead containers on node: ${host}..."
    ssh ubuntu@"${host}" 'docker container prune -f'
    echo "Done."
done
