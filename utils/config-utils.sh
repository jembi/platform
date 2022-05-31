#!/bin/bash

# Library name: config
# This is a library that contains functions to assist with docker configs

# Sets the digest variables for the conf raft files in the provided docker compose file

# Requirements:
# - All configs must have a file and name property
# - The name property must end in -${DIGEST_VAR_NAME:?err} (eg. name: my-file-${MY_FILE_DIGEST:?err})

# Arguments:
# $1 : docker compose directory path (eg. /home/user/project/docker-compose.yml)

# Exports:
# As many digest environment variables as are declared in the provided docker compose file
config::set_config_digests() {
    local -r DOCKER_COMPOSE_PATH=$1

    # Get configs files and names from yml file
    local -r files=($(yq '.configs."*.*".file' "${DOCKER_COMPOSE_PATH}"))
    local -r names=($(yq '.configs."*.*".name' "${DOCKER_COMPOSE_PATH}"))
    local -r composeFolderPath="${DOCKER_COMPOSE_PATH%/*}"

    for ((i = 0; i < ${#files[@]}; i++)); do
        file=${files[$i]}
        name=${names[$i]}

        fileName="${composeFolderPath}${file//\.\///}" # TODO: Throw an error if the file name is too long to allow for a unique enough digest
        envVarName=$(echo "${name}" | grep -P -o "{.*:?err}" | sed 's/[{}]//g' | sed 's/:?err//g')

        # generate and truncate the digest to conform to the 64 character restriction on docker config names
        remainder=$((64 - (${#name} - ${#envVarName} - 5))) # '${:?err}' = 5 characters (for env var declaration characters)
        export "${envVarName}"="$(cksum "${fileName}" | awk '{print $1}' | cut -c -${remainder})"
    done
}

# Removes stale docker configs based on the provided docker-compose file
#
# Requirements:
# - All configs must have a file and name property
# - The name property must end in -${DIGEST_VAR_NAME:?err} (eg. name: my-file-${MY_FILE_DIGEST:?err})
#
# Arguments:
# $1 : docker compose directory path (eg. /home/user/project/docker-compose.yml)
# $2 : config label (eg. logstash)
config::remove_stale_service_configs() {
    local -r DOCKER_COMPOSE_PATH=$1
    local -r CONFIG_LABEL=$2

    local -r composeNames=($(yq '.configs."*.*".name' "${DOCKER_COMPOSE_PATH}"))
    local configsToRemove=()

    for composeName in "${composeNames[@]}"; do
        composeNameWithoutEnv=$(echo "${composeName}" | sed 's/-\${.*//g')

        composeNameOccurences=$(for word in "${composeNames[@]}"; do echo "${word}"; done | grep -c "${composeNameWithoutEnv}")
        if [[ $composeNameOccurences -gt "1" ]]; then
            echo >&2 "Warning: Duplicate config name (${composeNameWithoutEnv}) was found in ${DOCKER_COMPOSE_PATH}"
        fi

        raftIds=($(docker config ls -f "label=name=${CONFIG_LABEL}" -f "name=${composeNameWithoutEnv}" --format "{{.ID}}"))

        # Only keep the most recent of all configs with the same name
        if [[ ${#raftIds[@]} -gt 1 ]]; then
            mostRecentRaftId="${raftIds[0]}"
            for ((i = 1; i < ${#raftIds[@]}; i++)); do
                raftId=${raftIds[$i]}
                mostRecentRaftCreatedDate=$(docker config inspect -f "{{.CreatedAt}}" "${mostRecentRaftId}")
                raftCreatedDate=$(docker config inspect -f "{{.CreatedAt}}" "${raftId}")
                if [[ $raftCreatedDate > $mostRecentRaftCreatedDate ]]; then
                    configsToRemove+=("${mostRecentRaftId}")
                    mostRecentRaftId="${raftId}"
                else
                    configsToRemove+=("${raftId}")
                fi
            done
        fi
    done

    # Remove configs without a reference
    configRaftNames=($(docker config ls -f "label=name=${CONFIG_LABEL}" --format "{{.Name}}"))
    for configRaftName in "${configRaftNames[@]}"; do
        nameWithoutDigest=$(echo $configRaftName | sed 's/-[a-f0-9]*$//g')
        raftOccurencesInCompose=$(for word in "${composeNames[@]}"; do echo "${word}"; done | grep -c "${nameWithoutDigest}")

        if [[ "${raftOccurencesInCompose}" == 0 ]]; then
            configsToRemove+=("${configRaftName}")
        fi
    done

    docker config rm "${configsToRemove[@]}"
}

# Copies sharedConfigs into a package's container root directory

# Requirements:
# - The package-metadata.json file requires a sharedConfigs property with an array of shared directories/files

# Arguments:
# $1 : package metadata path (eg. /home/user/project/platform-implementation/packages/package/package-metadata.json)
# $2 : container destination (eg. /usr/share/logstash/)
# $3 : service id (eg. data-mapper-logstash) (tries to retrieve service name from package-metadata if not provided)
config::copy_shared_configs() {
    local -r PACKAGE_METADATA_PATH=$1
    local -r CONTAINER_DESTINATION=$2
    local serviceId=$3

    local -r sharedConfigs=($(jq '.sharedConfigs[]' "${PACKAGE_METADATA_PATH}"))
    local -r packageBaseDir=$(dirname "${PACKAGE_METADATA_PATH}")
    local -r containerId=$(docker container ls -qlf name=instant_"${serviceId}")

    for sharedConfig in "${sharedConfigs[@]}"; do
        # TODO: (https://jembiprojects.jira.com/browse/PLAT-252) swap docker copy for a swarm compliant approach
        docker cp -a "${packageBaseDir}""${sharedConfig//\"//}" "${containerId}":"${CONTAINER_DESTINATION}"
    done
}

# A function that exists in a loop to see how long that loop has run for, providing a warning
# at the time specified in argument $3, and exits with code 124 after the time specified in argument $4.
#
# Arguments:
# $1 : start time of the timeout check
# $2 : a message containing reference to the loop that timed out
# $3 : timeout time in seconds, default is 300 seconds
# $4 : elapsed time to issue running-for-longer-than-expected warning (in seconds), default is 60 seconds
config::timeout_check() {
    local startTime=$(($1))
    local message=$2
    local exitTime="${3:-300}"
    local warningTime="${4:-60}"

    local timeDiff=$(($(date +%s) - $startTime))
    if [[ $timeDiff -ge $warningTime ]] && [[ $timeDiff -lt $(($warningTime + 1)) ]]; then
        echo "Warning: Waited $warningTime seconds for $message. This is taking longer than it should..."
    elif [[ $timeDiff -ge $exitTime ]]; then
        echo "Fatal: Waited $exitTime seconds for $message. Exiting..."
        exit 124
    fi
}

# A generic function confirming whether or not a containerized api is reachable
#
# Requirements:
# - The function attempts to start up a helper container using the jembi/await-helper image. It is therefore necessary
#   to specify the docker-compose file to deploy the await-helper container which the await_service_running function
#   relies on. Details on configuring the await-helper can be found at https://github.com/jembi/platform-await-helper.
#
# Arguments:
# $1 : the service being awaited
# $2 : path to await-helper compose.yml file (eg. ~/projects/platform/dashboard-visualiser-jsreport/docker-compose.await-helper.yml)
# $3 : desired number of instances of the awaited-service
# $4 : (optional) the max time allowed to wait for a service's response, defaults to 300 seconds
# $5 : (optional) elapsed time to throw a warning, defaults to 60 seconds
config::await_service_running() {
    local -r service_name="${1:?"FATAL: await_service_running function args not correctly set"}"
    local -r await_helper_file_path="${2:?"FATAL: await_service_running function args not correctly set"}"
    local -r service_instances="${3:?"FATAL: await_service_running function args not correctly set"}"
    local -r exit_time="${4:-}"
    local -r warning_time="${5:-}"
    local -r start_time=$(date +%s)

    docker stack deploy -c "$await_helper_file_path" instant
    until [[ $(docker service ls -f name=instant_"$service_name" --format "{{.Replicas}}") == *"$service_instances/$service_instances"* ]]; do
        config::timeout_check "$start_time" "$service_name to start" "$exit_time" "$warning_time"
        sleep 1
    done

    local await_helper_state
    await_helper_state=$(docker service ps instant_await-helper --format "{{.CurrentState}}")
    until [[ $await_helper_state == *"Complete"* ]]; do
        config::timeout_check "$start_time" "$service_name status check" "$exit_time" "$warning_time"

        await_helper_state=$(docker service ps instant_await-helper --format "{{.CurrentState}}")
        if [[ $await_helper_state == *"Failed"* ]] || [[ $await_helper_state == *"Rejected"* ]]; then
            echo "Fatal: Received error when trying to verify state of $service_name. Error:
       $(docker service ps instant_await-helper --no-trunc --format '{{.Error}}')"
            exit 1
        fi
    done

    docker service rm instant_await-helper
}

# A function which removes a config importing service on successful completion, and exits with an error otherwise
#
# Arguments:
# $1 : the name of the config importer
# $2 : (optional) the timeout time for the config importer to run, defaults to 300 seconds
# $3 : (optional) elapsed time to throw a warning, defaults to 60 seconds
config::remove_config_importer() {
    local -r config_importer_service_name="${1:?"FATAL: remove_config_importer function args not correctly set"}"
    local -r exit_time="${2:-}"
    local -r warning_time="${3:-}"
    local -r start_time=$(date +%s)

    local config_importer_state
    config_importer_state=$(docker service ps instant_"$config_importer_service_name" --format "{{.CurrentState}}")
    until [[ $config_importer_state == *"Complete"* ]]; do
        config::timeout_check "$start_time" "$config_importer_service_name to run" "$exit_time" "$warning_time"
        sleep 1

        config_importer_state=$(docker service ps instant_"$config_importer_service_name" --format "{{.CurrentState}}")
        if [[ $config_importer_state == *"Failed"* ]] || [[ $config_importer_state == *"Rejected"* ]]; then
            echo "Fatal: $config_importer_service_name failed with error:
       $(docker service ps instant_"$config_importer_service_name" --no-trunc --format '{{.Error}}')"
            exit 1
        fi
    done

    docker service rm instant_"$config_importer_service_name"
}

# Waits for the provided service to be removed
#
# Arguments:
# $1 : service name (eg. instant_analytics-datastore-elastic-search)
config::await_service_removed() {
    local -r SERVICE_NAME="${1:?"FATAL: await_service_removed SERVICE_NAME not provided"}"
    local start_time=$(date +%s)

    until [[ -z $(docker service ls -qf name="${SERVICE_NAME}") ]]; do
        config::timeout_check $start_time "${SERVICE_NAME} to be removed"
        sleep 1
    done
}
