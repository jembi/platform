#!/bin/bash

GITHUB_RUN_ID=$1
NODE_MODE=$2
shift
shift
CHANGED_FILES=($@)

cd ../../test/cucumber/ || exit

# This ensures that the openhim and its mediators' tests are run only once when the openhim and its mediators have all been modified
openhimRan="false"

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

function run_test() {
   DOCKER_HOST=ssh://ubuntu@$GITHUB_RUN_ID.jembi.cloud HOST=$GITHUB_RUN_ID.jembi.cloud yarn test:"$NODE_MODE":$1
}

# Run the basic funtional end to end tests for the CDR recipe
run_test "recipe"

if [[ ${#changed_packages[@]} -eq 0 ]] || [[ "${!changed_packages[*]}" == *"utils"* ]] || [[ "${!changed_packages[*]}" == *"features/steps"* ]] || [[ "${!changed_packages[*]}" == *"infrastructure"* ]] ; then
    openhimRan="true"
    run_test "openhim"
else
    for folder_name in "${!changed_packages[@]}"; do
        echo "$folder_name was changed"

        if [[ $folder_name == *"clickhouse"* ]]; then
            run_test "clickhouse"
        elif [[ $folder_name == *"elastic"* ]] || [[ $folder_name == *"kibana"* ]] || [[ $folder_name == *"logstash"* ]]; then
            run_test "elk"
        elif [[ $folder_name == *"kafka"* ]] || [[ $folder_name == *"monitoring"* ]]; then
            run_test "kafka"
        elif [[ $folder_name == *"openhim"* ]] && [[ $openhimRan == "false" ]]; then
            openhimRan="true"
            run_test "openhim"
        elif [[ $folder_name == *"reverse-proxy"* ]]; then
            run_test "nginx"
        elif [[ $folder_name == *"hapi"* ]]; then
            run_test "hapi"
        elif [[ $folder_name == *"santempi"* ]]; then
            run_test "sante"
        elif [[ $folder_name == *"monitoring"* ]]; then
            run_test "monitoring"
        elif [[ $folder_name == *"keycloak"* ]]; then
            run_test "keycloak"
        elif [[ $folder_name == *"superset"* ]] && [[ $NODE_MODE == "single" ]]; then
            run_test "superset"
        elif [[ $folder_name == *"jsreport"* ]] && [[ $NODE_MODE == "single" ]]; then
            run_test "jsreport"
        elif [[ $folder_name == *"mpi-mediator"* ]] && [[ $NODE_MODE == "single" ]]; then
            run_test "mpi-mediator"
        elif [[ $folder_name == *"jempi"* ]] && [[ $NODE_MODE == "single" ]]; then
            run_test "jempi"
        fi
    done
fi
