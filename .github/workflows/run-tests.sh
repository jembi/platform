#!/bin/bash

GITHUB_RUN_ID=$1
NODE_MODE=$2
shift
shift
CHANGED_FILES=($@)

cd ../../test/cucumber/ || exit

echo "GITHUB: $GITHUB_RUN_ID"
echo "NODE_MODE: $NODE_MODE"
echo "CHANGED: ${CHANGED_FILES[*]}"
for folder_name in "${CHANGED_FILES[@]}"; do
    echo "$folder_name was changed"

    if [[ $folder_name == *"clickhouse"* ]]; then
        DOCKER_HOST=ssh://ubuntu@$GITHUB_RUN_ID.jembi.cloud yarn test:"$NODE_MODE":clickhouse
    elif [[ $folder_name == *"elastic"* ]] || [[ $folder_name == *"kibana"* ]] || [[ $folder_name == *"logstash"* ]]; then
        DOCKER_HOST=ssh://ubuntu@$GITHUB_RUN_ID.jembi.cloud yarn test:"$NODE_MODE":elk
    elif [[ $folder_name == *"kafka"* ]] || [[ $folder_name == *"monitoring"* ]]; then
        DOCKER_HOST=ssh://ubuntu@$GITHUB_RUN_ID.jembi.cloud yarn test:"$NODE_MODE":kafka
    elif [[ $folder_name == *"openhim"* ]] || [[ $folder_name == *"client-registry-jempi"* ]]; then
        DOCKER_HOST=ssh://ubuntu@$GITHUB_RUN_ID.jembi.cloud yarn test:"$NODE_MODE":openhim
    elif [[ $folder_name == *"reverse-proxy"* ]]; then
        DOCKER_HOST=ssh://ubuntu@$GITHUB_RUN_ID.jembi.cloud yarn test:"$NODE_MODE":nginx
    elif [[ $folder_name == *"hapi"* ]]; then
        DOCKER_HOST=ssh://ubuntu@$GITHUB_RUN_ID.jembi.cloud yarn test:"$NODE_MODE":hapi
    elif [[ $folder_name == *"santempi"* ]]; then
        DOCKER_HOST=ssh://ubuntu@$GITHUB_RUN_ID.jembi.cloud yarn test:"$NODE_MODE":sante
    elif [[ $folder_name == *"utils"* ]]; then
        DOCKER_HOST=ssh://ubuntu@$GITHUB_RUN_ID.jembi.cloud yarn test:"$NODE_MODE"
    elif [[ $folder_name == *"single-mode"* ]]; then
        DOCKER_HOST=ssh://ubuntu@$GITHUB_RUN_ID.jembi.cloud yarn test:single
    elif [[ $folder_name == *"cluster-mode"* ]]; then
        DOCKER_HOST=ssh://ubuntu@$GITHUB_RUN_ID.jembi.cloud yarn test:cluster
    elif [[ $folder_name == *"test"* ]]; then
        DOCKER_HOST=ssh://ubuntu@$GITHUB_RUN_ID.jembi.cloud yarn test:"$NODE_MODE"

    fi
done

if [[ ${#CHANGED_FILES[@]} -eq 0 ]]; then
    DOCKER_HOST=ssh://ubuntu@$GITHUB_RUN_ID.jembi.cloud yarn test:"$NODE_MODE"
fi
