#!/bin/bash
#
# Library name: config
# This is a library that contains functions to assist with docker configs
#
# For functions using `declare -n`, note the following explanation https://linuxhint.com/bash_declare_command/#:~:text=giving%20them%20attributes.-,Namerefs,-If%20you%20are

. "$(pwd)/utils/log.sh"

#######################################
#
# Sets the digest variables for the conf raft files in the provided docker compose file
#
# Requirements:
# - All configs must have a file and name property
# - The name property must end in -${DIGEST_VAR_NAME:?err} (eg. name: my-file-${MY_FILE_DIGEST:?err})
#
# Arguments:
# - $1 : docker compose directory path (eg. /home/user/project/docker-compose.yml)
#
# Exports:
# As many digest environment variables as are declared in the provided docker compose file
#
#######################################
config::set_config_digests() {
    local -r DOCKER_COMPOSE_PATH="${1:?"FATAL: function 'set_config_digests' is missing a parameter"}"

    # Get configs files and names from yml file
    local -r files=($(yq '.configs."*.*".file' "${DOCKER_COMPOSE_PATH}"))
    local -r names=($(yq '.configs."*.*".name' "${DOCKER_COMPOSE_PATH}"))
    local -r compose_folder_path="${DOCKER_COMPOSE_PATH%/*}"

    if [[ "${files[*]}" != *"null"* ]] && [[ "${names[*]}" != *"null"* ]]; then
        log info "Setting config digests"

        for ((i = 0; i < ${#files[@]}; i++)); do
            file=${files[$i]}
            name=${names[$i]}

            file_name="${compose_folder_path}${file//\.\///}" # TODO: Throw an error if the file name is too long to allow for a unique enough digest
            env_var_name=$(echo "${name}" | grep -P -o "{.*:?err}" | sed 's/[{}]//g' | sed 's/:?err//g')

            if [[ -n "$env_var_name" ]]; then
                # generate and truncate the digest to conform to the 64 character restriction on docker config names
                env_declaration_characters=":?err" # '${:?err}' from setting an env variable
                remainder=$((64 - (${#name} - ${#env_var_name} - ${#env_declaration_characters})))
                export "${env_var_name}"="$(cksum "${file_name}" | awk '{print $1}' | cut -c -${remainder})"
            fi
        done
    elif [[ "${files[*]}" == *"null"* ]]; then
        log error "No files found to set the digest in:\n $DOCKER_COMPOSE_PATH"
        exit 1
    else
        log error "You should specify names for the files in:\n $DOCKER_COMPOSE_PATH"
        exit 1
    fi
}

#######################################
#
# Removes stale docker configs based on the provided docker-compose file
#
# Requirements:
# - All configs must have a file and name property
# - The name property must end in -${DIGEST_VAR_NAME:?err} (eg. name: my-file-${MY_FILE_DIGEST:?err})
#
# Arguments:
# - $1 : docker compose directory path (eg. /home/user/project/docker-compose.yml)
# - $2 : config label (eg. logstash)
#
#######################################
config::remove_stale_service_configs() {
    local -r DOCKER_COMPOSE_PATH="${1:?"FATAL: function 'remove_stale_service_configs' is missing a parameter"}"
    local -r CONFIG_LABEL="${2:?"FATAL: function 'remove_stale_service_configs' is missing a parameter"}"

    local -r compose_names=($(yq '.configs."*.*".name' "${DOCKER_COMPOSE_PATH}"))
    local configs_to_remove=()

    if [[ "${compose_names[*]}" != "null" ]]; then
        for compose_name in "${compose_names[@]}"; do
            compose_name_without_env=$(echo "${compose_name}" | sed 's/-\${.*//g')

            compose_name_occurences=$(for word in "${compose_names[@]}"; do echo "${word}"; done | grep -c "${compose_name_without_env}")
            if [[ $compose_name_occurences -gt "1" ]]; then
                log warn "Warning: Duplicate config name (${compose_name_without_env}) was found in ${DOCKER_COMPOSE_PATH}"
            fi

            raft_ids=($(docker config ls -f "label=name=${CONFIG_LABEL}" -f "name=${compose_name_without_env}" --format "{{.ID}}"))
            # Only keep the most recent of all configs with the same name
            if [[ ${#raft_ids[@]} -gt 1 ]]; then
                most_recent_raft_id="${raft_ids[0]}"
                for ((i = 1; i < ${#raft_ids[@]}; i++)); do
                    raft_id=${raft_ids[$i]}
                    most_recent_raft_created_date=$(docker config inspect -f "{{.CreatedAt}}" "${most_recent_raft_id}")
                    raft_created_date=$(docker config inspect -f "{{.CreatedAt}}" "${raft_id}")
                    if [[ $raft_created_date > $most_recent_raft_created_date ]]; then
                        configs_to_remove+=("${most_recent_raft_id}")
                        most_recent_raft_id="${raft_id}"
                    else
                        configs_to_remove+=("${raft_id}")
                    fi
                done
            fi
        done
    else
        log warn "No name files found in the compose config to be removed"
    fi

    if [[ "${#configs_to_remove[@]}" -gt 0 ]]; then
        try \
            "docker config rm ${configs_to_remove[*]}" \
            catch \
            "Failed to remove configs: ${configs_to_remove[*]}"
    fi
}

#######################################
#
# A function that exists in a loop to see how long that loop has run for, providing a warning
# at the time specified in argument $3, and exits with code 124 after the time specified in argument $4.
#
# Arguments:
# - $1 : start time of the timeout check
# - $2 : a message containing reference to the loop that timed out
# - $3 : timeout time in seconds, default is 300 seconds
# - $4 : elapsed time to issue running-for-longer-than-expected warning (in seconds), default is 60 seconds
#
#######################################
config::timeout_check() {
    local start_time=$(($1))
    local message=$2
    local exit_time="${3:-300}"
    local warning_time="${4:-60}"

    local timeDiff=$(($(date +%s) - $start_time))
    if [[ $timeDiff -ge $warning_time ]] && [[ $timeDiff -lt $(($warning_time + 1)) ]]; then
        log warn "Warning: Waited $warning_time seconds for $message. This is taking longer than it should..."
    elif [[ $timeDiff -ge $exit_time ]]; then
        log error "Fatal: Waited $exit_time seconds for $message. Exiting..."
        exit 124
    fi
}

#######################################
#
# A generic function confirming whether or not a containerized api is reachable
#
# Requirements:
# - The function attempts to start up a helper container using the jembi/await-helper image. It is therefore necessary
#   to specify the docker-compose file to deploy the await-helper container which the await_service_running function
#   relies on. Details on configuring the await-helper can be found at https://github.com/jembi/platform-await-helper.
#
# Arguments:
# - $1 : the service being awaited
# - $2 : path to await-helper compose.yml file (eg. ~/projects/platform/dashboard-visualiser-jsreport/docker-compose.await-helper.yml)
# - $3 : desired number of instances of the awaited-service
# - $4 : (optional) the max time allowed to wait for a service's response, defaults to 300 seconds
# - $5 : (optional) elapsed time to throw a warning, defaults to 60 seconds
#
#######################################
config::await_service_running() {
    local -r service_name="${1:?"FATAL: await_service_running function args not correctly set"}"
    local -r await_helper_file_path="${2:?"FATAL: await_service_running function args not correctly set"}"
    local -r service_instances="${3:?"FATAL: await_service_running function args not correctly set"}"
    local -r exit_time="${4:-}"
    local -r warning_time="${5:-}"
    local -r start_time=$(date +%s)

    docker service rm instant_await-helper &>/dev/null

    try "docker stack deploy -c $await_helper_file_path instant" catch "Failed to deploy await helper"
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
            log error "Fatal: Received error when trying to verify state of $service_name. Error:
       $(docker service ps instant_await-helper --no-trunc --format '{{.Error}}')"
            exit 1
        fi
    done

    try "docker service rm instant_await-helper" catch "Failed to remove await-helper"
}

#######################################
#
# A function which removes a config importing service on successful completion, and exits with an error otherwise
#
# Arguments:
# - $1 : the name of the config importer
# - $2 : (optional) the timeout time for the config importer to run, defaults to 300 seconds
# - $3 : (optional) elapsed time to throw a warning, defaults to 60 seconds
#
#######################################
config::remove_config_importer() {
    local -r config_importer_service_name="${1:?"FATAL: remove_config_importer function args not correctly set"}"
    local -r exit_time="${2:-}"
    local -r warning_time="${3:-}"
    local -r start_time=$(date +%s)

    local config_importer_state

    if [[ -z $(docker service ps instant_"$config_importer_service_name") ]]; then
        log info "instant_$config_importer_service_name service cannot be removed as it does not exist!"
        exit 0
    fi

    config_importer_state=$(docker service ps instant_"$config_importer_service_name" --format "{{.CurrentState}}")
    until [[ $config_importer_state == *"Complete"* ]]; do
        config::timeout_check "$start_time" "$config_importer_service_name to run" "$exit_time" "$warning_time"
        sleep 1

        config_importer_state=$(docker service ps instant_"$config_importer_service_name" --format "{{.CurrentState}}")
        if [[ $config_importer_state == *"Failed"* ]] || [[ $config_importer_state == *"Rejected"* ]]; then
            log error "Fatal: $config_importer_service_name failed with error:
       $(docker service ps instant_"$config_importer_service_name" --no-trunc --format '{{.Error}}')"
            exit 1
        fi
    done

    try "docker service rm instant_$config_importer_service_name" catch "Failed to remove config importer"
}

#######################################
#
# Waits for the provided service to be removed
#
# Arguments:
# - $1 : service name (eg. instant_analytics-datastore-elastic-search)
#
#######################################
config::await_service_removed() {
    local -r SERVICE_NAME="${1:?"FATAL: await_service_removed SERVICE_NAME not provided"}"
    local start_time=$(date +%s)

    until [[ -z $(docker stack ps instant -qf name="${SERVICE_NAME}" 2>/dev/null) ]]; do
        config::timeout_check "$start_time" "${SERVICE_NAME} to be removed"
        sleep 1
    done
    log info "Service $SERVICE_NAME successfully removed"
}

#######################################
#
# Waits for the provided service to join the network
#
# Arguments:
# $1 : service name (eg. instant_analytics-datastore-elastic-search)
#
#######################################
config::await_network_join() {
    local -r SERVICE_NAME="${1:?"FATAL: await_service_removed SERVICE_NAME not provided"}"
    local start_time=$(date +%s)
    local exit_time=30
    local warning_time=10

    log info "Waiting for ${SERVICE_NAME} to join network..."

    # TODO: do a better regex/string matching check to ensure that we don't accidentally
    # check for services with append to this service name, e.g., if we're looking for
    # instant_analytics-datastore-elastic-search and we have instant_analytics-datastore-elastic-search-helper
    # we could get a false-positive
    until [[ $(docker network inspect -v instant_default -f "{{.Services}}") == *"${SERVICE_NAME}"* ]]; do
        config::timeout_check "$start_time" "${SERVICE_NAME} to join the network" $exit_time $warning_time
        sleep 1
    done
}

#######################################
#
# Generates configs for a service from a folder and adds them to a temp docker-compose file
#
# Arguments:
# - $1 : service name (eg. data-mapper-logstash)
# - $2 : target base (eg. /usr/share/logstash/)
# - $3 : target folder path in absolute format (eg. "$PATH_TO_FILE"/pipeline)
# - $4 : compose file path (eg. "$PATH_TO_FILE")
#
# Exports:
# All exports are required for yq to process the values and are not intended for external use
# - service_config_query
# - config_target
# - config_source
# - config_query
# - config_file
# - config_label_name
# - config_service_name
#
#######################################
config::generate_service_configs() {
    local -r SERVICE_NAME=${1:?"FATAL: generate_service_config parameter missing"}
    local -r TARGET_BASE=${2:?"FATAL: generate_service_config parameter missing"}
    local -r TARGET_FOLDER_PATH=${3:?"FATAL: generate_service_config parameter missing"}
    local -r COMPOSE_PATH=${4:?"FATAL: generate_service_config parameter missing"}
    local -r LABEL_NAME=${5:?"FATAL: generate_service_config parameter missing"}
    local -r TARGET_FOLDER_NAME=$(basename "${TARGET_FOLDER_PATH}")
    local count=0

    try \
        "touch ${COMPOSE_PATH}/docker-compose.tmp.yml" \
        catch \
        "Failed to create temp service config compose file"

    find "${TARGET_FOLDER_PATH}" -maxdepth 10 -mindepth 1 -type f | while read -r file; do
        file_name=${file/"${TARGET_FOLDER_PATH%/}"/}
        file_name=${file_name:1}
        file_hash=$(cksum "${file}" | awk '{print $1}')

        # for these variables to be visible by yq they need to be exported
        export service_config_query=".services.${SERVICE_NAME}.configs[${count}]"
        export config_target="${TARGET_BASE%/}/${TARGET_FOLDER_NAME}/${file_name}"
        export config_source="${SERVICE_NAME}-${file_hash}"

        export config_query=".configs.${config_source}"
        export config_file="./${TARGET_FOLDER_NAME}/${file_name}"
        export config_label_name=$LABEL_NAME
        export config_service_name=$SERVICE_NAME

        yq -i '
        .version = "3.9" |
        eval(strenv(service_config_query)).target = env(config_target) |
        eval(strenv(service_config_query)).source = strenv(config_source) |
        eval(strenv(config_query)).file = strenv(config_file) |
        eval(strenv(config_query)).name = strenv(config_source) |
        eval(strenv(config_query)).labels.name = strenv(config_label_name) |
        eval(strenv(config_query)).labels.service = strenv(config_service_name)
        ' "${COMPOSE_PATH}/docker-compose.tmp.yml"

        count=$((count + 1))
    done
}

#######################################
#
# Removes nginx configs for destroyed services
#
# Arguments:
# - $@ : a list of configs to remove
#
#######################################
config::remove_service_nginx_config() {
    local configs=("$@")
    local config_rm_command=""
    local config_rm_list=""
    for config in "${configs[@]}"; do
        if [[ -n $(docker config ls -qf name="$config") ]]; then
            config_rm_command="$config_rm_command --config-rm $config"
            config_rm_list="$config_rm_list $config"
        fi
    done

    try "docker service update $config_rm_command instant_reverse-proxy-nginx" catch "Error updating nginx service"
    try "docker config rm $config_rm_list" catch "Failed to remove configs"
}

#######################################
#
# Replaces all environment variables in a file with the environment variable value
# Arguments:
# - $1 : the path to the file that you wish to substitute env vars into (eg. "${COMPOSE_FILE_PATH}"/config.ini)
#
#######################################
config::substitute_env_vars() {
    local -r FILE_PATH="${1:?"substitute_env_vars is missing a parameter"}"
    config_with_env=$(envsubst <"${FILE_PATH}")
    echo "" >"${FILE_PATH}"
    echo "$config_with_env" >>"${FILE_PATH}"
}

#######################################
#
# Modify a variable to contain the necessary `--config-rm` and `--config-add` arguments to update a service's
# configs based off newly created docker configs for a provided folder. The modified variable must then be
# used in a `docker service update` command, like follows:
# ```
#   service_update_args=""
#   config::update_service_configs service_update_args /usr/share/logstash/ "$PATH_TO_FILE"/pipeline cares
#   docker service update $service_update_args instant_data-mapper-logstash
# ```
# Reference arguments:
# - $1 : config update variable name (eg. service_update_args)
#
# Arguments:
# - $2 : target base (eg. /usr/share/logstash/)
# - $3 : target folder path in absolute format (eg. "$PATH_TO_FILE"/pipeline)
# - $4 : config label name (eg. cares)
#
#######################################
config::update_service_configs() {
    declare -n REF_config_update_var="${1:?"FATAL: update_service_configs is missing a parameter"}"
    local -r TARGET_BASE=${2:?"FATAL: update_service_configs parameter missing"}
    local -r TARGET_FOLDER_PATH=${3:?"FATAL: update_service_configs parameter missing"}
    local -r CONFIG_LABEL_NAME="${4:?"FATAL: update_service_configs is missing a parameter"}"
    local config_rm_string=""
    local config_add_string=""

    files=$(find "${TARGET_FOLDER_PATH}" -maxdepth 10 -mindepth 1 -type f)

    for file in $files; do
        file_name=${file/"${TARGET_FOLDER_PATH%/}"/}
        file_name=${file_name:1}
        file_hash=$(md5sum "${file}" | awk '{print $1}')
        config_file="${TARGET_FOLDER_PATH}/${file_name}"
        config_target="${TARGET_BASE%/}/${file_name}"
        config_name=$(basename "$file_name")-$file_hash
        old_config_name=$(docker config inspect --format="{{.Spec.Name}}" "$(docker config ls -qf name="$(basename "$file_name")")" 2>/dev/null)

        if [[ "$config_name" != "$old_config_name" ]]; then
            if [[ -n $old_config_name ]]; then
                config_rm_string+="--config-rm $old_config_name "
            fi
            config_add_string+="--config-add source=$config_name,target=$config_target "

            try \
                "docker config create --label name=$CONFIG_LABEL_NAME $config_name $config_file" \
                catch \
                "Failed to create config"
        fi
    done

    REF_config_update_var+="$config_rm_string $config_add_string"
}

#######################################
#
# Modify a variable to contain the necessary `--env-add` arguments to update a service's
# environment specified in a .env file. The modified variable must then be
# used in a `docker service update` command, like follows:
# ```
#   service_update_args=""
#   config::env_var_add_from_file service_update_args "$PATH_TO_FILE"/.env.add
#   docker service update $service_update_args instant_data-mapper-logstash
# ```
# Reference arguments:
# - $1 : service update variable name (eg. service_update_args)
#
# Arguments:
# - $2 : .env file (eg. "$PATH_TO_FILE"/.env.add)
#
#######################################
config::env_var_add_from_file() {
    declare -n REF_service_update_var="${1:?"FATAL: env_var_add_from_file is missing a parameter"}"
    local -r ENV_FILE=${2:?"FATAL: env_var_add_from_file parameter missing"}

    if [[ ! -f $ENV_FILE ]]; then
        log error "$ENV_FILE: No such file or directory. Exiting..."
        return 1
    fi

    readarray -t env_vars <"$ENV_FILE"
    for env_var in "${env_vars[@]}"; do
        REF_service_update_var+=" --env-add $env_var"
    done
}

#######################################
#
# Modify a variable to contain the necessary `--env-add` arguments to update a service's
# environment based on the provided env var. The modified variable must then be
# used in a `docker service update` command, like follows:
# ```
#   service_update_args=""
#   config::env_var_add service_update_args MY_ENV_VAR=my_value
#   docker service update $service_update_args instant_data-mapper-logstash
# ```
# Reference arguments:
# - $1 : service update variable name (eg. service_update_args)
#
# Arguments:
# - $2 : env var (eg. MY_ENV_VAR=my_value)
#
#######################################
config::env_var_add() {
    declare -n REF_service_update_var="${1:?"FATAL: env_var_add is missing a parameter"}"
    local -r ENV_VAR=${2:?"FATAL: env_var_add parameter missing"}

    REF_service_update_var+=" --env-add $ENV_VAR"
}

#######################################
# Waits for the provided service to be reachable by checking logs
#
# Arguments:
# $1 : service name (eg. analytics-datastore-elastic-search)
# $2 : log string to be checked (eg. Starting)
#######################################
config::await_service_reachable() {
    local -r SERVICE_NAME=${1:?"FATAL: await_service_reachable SERVICE_NAME not provided"}
    local -r LOG_MESSAGE=${2:?"FATAL: await_service_reachable LOG_MESSAGE not provided"}
    local -r start_time=$(date +%s)

    until [[ $(docker service logs --tail all instant_"${SERVICE_NAME}" 2>/dev/null | grep -c "${LOG_MESSAGE}") -gt 0 ]]; do
        config::timeout_check "$start_time" "$SERVICE_NAME to be reachable"
        sleep 1
    done
}
