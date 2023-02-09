#!/bin/bash

GITHUB_RUN_ID=$1
NODE_MODE=$2
shift
shift
CHANGED_FILES=($@)

cd ../../test/cucumber/ || exit

declare -A changed_packages
for package in "${CHANGED_FILES[@]}"; do
    if [[ $package == *"features/cluster-mode"* ]]; then
        changed_packages["features/cluster-mode"]="true"

    elif [[ $package == *"features/single-mode"* ]]; then
        changed_packages["features/single-mode"]="true"

    else
        IFS='/' read -r -a split_string <<<"$package"
        changed_packages["${split_string[0]}"]="true"
        
    fi
done

if [[ ${#changed_packages[@]} -eq 0 ]] || [[ "${!changed_packages[*]}" == *"utils"* ]]; then
    DOCKER_HOST=ssh://ubuntu@$GITHUB_RUN_ID.jembi.cloud yarn test:"$NODE_MODE"
elif [[ "${!changed_packages[*]}" == *"features/single-mode"* ]] && [[ $NODE_MODE == "single" ]]; then
    DOCKER_HOST=ssh://ubuntu@$GITHUB_RUN_ID.jembi.cloud yarn test:single
elif [[ "${!changed_packages[*]}" == *"features/cluster-mode"* ]] && [[ $NODE_MODE == "cluster" ]]; then
    DOCKER_HOST=ssh://ubuntu@$GITHUB_RUN_ID.jembi.cloud yarn test:cluster
elif [[ "${!changed_packages[*]}" == *"infrastructure"* ]]; then
    DOCKER_HOST=ssh://ubuntu@$GITHUB_RUN_ID.jembi.cloud yarn test:"$NODE_MODE"
else
    for folder_name in "${!changed_packages[@]}"; do
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
        fi
    done
fi
