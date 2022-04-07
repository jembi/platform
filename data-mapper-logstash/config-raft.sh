#!/bin/bash
#
# Sets the digest variables for the conf raft files in the provided docker compose file
#
# Caveats:
# All configs must have a file and name property
# The name property must end in ${DIGEST_VAR_NAME} (eg. name: my-file-${MY_FILE_DIGEST})
#
# Arguments:
# $1 : docker compose directory path

readonly DOCKER_COMPOSE_PATH=$1

# Get configs files and names
files=($(yq '.configs."*.*".file' "$DOCKER_COMPOSE_PATH"))
names=($(yq '.configs."*.*".name' "$DOCKER_COMPOSE_PATH"))

for ((i = 0; i < ${#files[@]}; i++)); do
    file=${files[$i]}
    name=${names[$i]}

    composeFolderPath="${DOCKER_COMPOSE_PATH%/*}"
    fileName="${composeFolderPath}${file//\.\///}"
    envVarName=$(echo "${name}" | grep -P -o "{.*}" | sed 's/[{}]//g')

    remainder=$((64 - (${#name} - ${#envVarName} - 3))) # '${}' = 3 (for env var declaration characters)
    export "${envVarName}"="$(cksum "${fileName}" | awk '{print $1}' | cut -c -${remainder})"
done
