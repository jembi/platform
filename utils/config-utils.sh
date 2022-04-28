#!/bin/bash
#
# Library name: config
# This is a library that contains functions to assist with docker configs

# Sets the digest variables for the conf raft files in the provided docker compose file
#
# Requirements:
# - All configs must have a file and name property
# - The name property must end in -${DIGEST_VAR_NAME:?err} (eg. name: my-file-${MY_FILE_DIGEST:?err})
#
# Arguments:
# $1 : docker compose directory path (eg. /home/user/project/docker-compose.yml)
#
# Exports:
# As many digest environment variables as are declared in the provided docker compose file
config::set_config_digests() {
    local -r DOCKER_COMPOSE_PATH=$1

    # install dependencies
    if [[ -z $(command -v wget) ]]; then
        apt install wget -y &>/dev/null
    fi
    if [[ -z $(command -v yq) ]]; then
        wget https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_amd64 -O /usr/bin/yq &>/dev/null
        chmod +x /usr/bin/yq
    fi

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

    # install dependencies
    if [[ -z $(command -v wget) ]]; then
        apt install wget -y &>/dev/null
    fi
    if [[ -z $(command -v yq) ]]; then
        wget https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_amd64 -O /usr/bin/yq &>/dev/null
        chmod +x /usr/bin/yq
    fi

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

# Copies sharedConfigs into a package's root directory
#
# Requirements:
# - The package-metadata.json file requires a sharedConfigs property with an array of shared directories/files
#
# Arguments:
# $1 : package metadata path (eg. /home/user/project/platform-implementation/packages/package/package-metadata.json)
# $2 : container destination (eg. /usr/share/logstash/)
# $3 : service id (eg. data-mapper-logstash) (tries to retrieve service name from package-metadata if not provided)
config::copy_shared_configs() {
    local -r PACKAGE_METADATA_PATH=$1
    local -r CONTAINER_DESTINATION=$2
    local serviceId=$3

    if [[ -z $SERVICE_ID ]]; then
        serviceId=$(jq '.id' "${PACKAGE_METADATA_PATH}" | sed 's/\"//g')
    fi

    # install dependencies
    if [[ -z $(command -v jq) ]]; then
        apt install jq -y &>/dev/null
    fi

    local -r sharedConfigs=($(jq '.sharedConfigs[]' "${PACKAGE_METADATA_PATH}"))
    local -r packageBaseDir=$(dirname "${PACKAGE_METADATA_PATH}")
    local -r containerId=$(docker container ls -qlf name=instant_"${serviceId}")

    for sharedConfig in "${sharedConfigs[@]}"; do
        # TODO: (https://jembiprojects.jira.com/browse/PLAT-243) swap docker copy for a swarm compliant approach
        docker cp "${packageBaseDir}"/"${sharedConfig//\"//}" "${containerId}":"${CONTAINER_DESTINATION}"
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
