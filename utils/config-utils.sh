#!/bin/bash
#
# Library name: config
# This is a library that contains functions to assist with docker configs
#

# Sets the digest variables for the conf raft files in the provided docker compose file
#
# Requirements:
# - All configs must have a file and name property
# - The name property must end in ${DIGEST_VAR_NAME:?err} (eg. name: my-file-${MY_FILE_DIGEST:?err})
#
# Arguments:
# $1 : docker compose directory path (eg. /home/user/project/docker-compose.yml)
#
# Exports:
# As many digest environment variables as are declared in the provided docker compose file
config::set_config_digests() {
    local -r DOCKER_COMPOSE_PATH=$1

    # install dependencies
    if [[ -z $(command -v wget >/dev/null 2>&1) ]]; then
        apt install wget -y >/dev/null 2>&1
    fi
    if [[ -z $(command -v yq >/dev/null 2>&1) ]]; then
        wget https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_amd64 -O /usr/bin/yq >/dev/null 2>&1
        chmod +x /usr/bin/yq
    fi

    # Get configs files and names from yml file
    local files=($(yq '.configs."*.*".file' "${DOCKER_COMPOSE_PATH}"))
    local names=($(yq '.configs."*.*".name' "${DOCKER_COMPOSE_PATH}"))

    for ((i = 0; i < ${#files[@]}; i++)); do
        file=${files[$i]}
        name=${names[$i]}

        composeFolderPath="${DOCKER_COMPOSE_PATH%/*}"
        fileName="${composeFolderPath}${file//\.\///}" # TODO: Throw an error if the file name is too long to allow for a unique enough digest
        envVarName=$(echo "${name}" | grep -P -o "{.*:?err}" | sed 's/[{}]//g' | sed 's/:?err//g')

        # generate and truncate the digest to conform to the 64 character restriction on docker config names
        remainder=$((64 - (${#name} - ${#envVarName} - 5))) # '${:?err}' = 5 (for env var declaration characters)
        export "${envVarName}"="$(cksum "${fileName}" | awk '{print $1}' | cut -c -${remainder})"
    done
}
