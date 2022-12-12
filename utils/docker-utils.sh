#!/bin/bash
#
# Library name: docker
# This is a library that contains functions to assist with docker actions

. "$(pwd)/utils/config-utils.sh"
. "$(pwd)/utils/log.sh"

# Waits for a container to be up
#
# Arguments:
# - $1 : service name (eg. analytics-datastore-elastic-search)
#
docker::await_container_startup() {
    local -r SERVICE_NAME=${1:?"FATAL: await_container_startup SERVICE_NAME not provided"}

    log info "Waiting for ${SERVICE_NAME} to start up..."
    local start_time
    start_time=$(date +%s)
    until [[ -n $(docker service ls -qf name=instant_"${SERVICE_NAME}") ]]; do
        config::timeout_check "${start_time}" "${SERVICE_NAME} to start"
        sleep 1
    done
    overwrite "Waiting for ${SERVICE_NAME} to start up... Done"
}

# Waits for a container to be up
#
# Arguments:
# - $1 : service name (eg. analytics-datastore-elastic-search)
# - $2 : service status (eg. running)
#
docker::await_container_status() {
    local -r SERVICE_NAME=${1:?"FATAL: await_container_startup parameter not provided"}
    local -r SERVICE_STATUS=${2:?"FATAL: await_container_startup parameter not provided"}

    log info "Waiting for ${SERVICE_NAME} to be ${SERVICE_STATUS}..."
    local -r start_time=$(date +%s)
    error_message=()
    until [[ $(docker service ps instant_"${SERVICE_NAME}" --format "{{.CurrentState}}" 2>/dev/null) == *"${SERVICE_STATUS}"* ]]; do
        config::timeout_check "${start_time}" "${SERVICE_NAME} to start"
        sleep 1

        # Get unique error messages using sort -u
        new_error_message=($(docker service ps instant_"$SERVICE_NAME" --no-trunc --format '{{ .Error }}' 2>&1 | sort -u))
        if [[ -n ${new_error_message[*]} ]]; then
            # To prevent logging the same error
            if [[ "${error_message[*]}" != "${new_error_message[*]}" ]]; then
                error_message=(${new_error_message[*]})
                log error "Deploy error in service $SERVICE_NAME: ${error_message[*]}"
            fi
        fi
    done
    overwrite "Waiting for ${SERVICE_NAME} to be ${SERVICE_STATUS}... Done"
}

# Waits for a container to be destroyed
#
# Arguments:
# - $1 : service name (eg. analytics-datastore-elastic-search)
#
docker::await_container_destroy() {
    local -r SERVICE_NAME=${1:?"FATAL: await_container_destroy SERVICE_NAME not provided"}

    log info "Waiting for ${SERVICE_NAME} to be destroyed..."
    local start_time
    start_time=$(date +%s)
    until [[ -z $(docker ps -qlf name="instant_${SERVICE_NAME}") ]]; do
        config::timeout_check "${start_time}" "${SERVICE_NAME} to be destroyed"
        sleep 1
    done
    overwrite "Waiting for ${SERVICE_NAME} to be destroyed... Done"
}

# Waits for a service to be destroyed
#
# Arguments:
# - $1 : service name (eg. analytics-datastore-elastic-search)
#
docker::await_service_destroy() {
    local -r SERVICE_NAME=${1:?"FATAL: await_container_destroy SERVICE_NAME not provided"}

    log info "Waiting for ${SERVICE_NAME} to be destroyed..."
    local start_time
    start_time=$(date +%s)
    while docker service ls | grep -q "\sinstant_${SERVICE_NAME}\s"; do
        config::timeout_check "${start_time}" "${SERVICE_NAME} to be destroyed"
        sleep 1
    done
    overwrite "Waiting for ${SERVICE_NAME} to be destroyed... Done"
}

# Removes a services containers then the service itself
# This was created to aid in removing volumes,
# since volumes being removed were still attached to some lingering containers after container remove
#
# Arguments:
# - $1 : service name (eg. analytics-datastore-elastic-search)
#
docker::service_destroy() {
    local -r SERVICE_NAME=${1:?"FATAL: await_container_destroy SERVICE_NAME not provided"}

    log info "Waiting for service $SERVICE_NAME to be removed ... "
    if [[ -n $(docker service ls -qf name=instant_"${SERVICE_NAME}") ]]; then
        try "docker service scale instant_${SERVICE_NAME}=0" catch "Failed to scale down ${SERVICE_NAME}"
        try "docker service rm instant_${SERVICE_NAME}" catch "Failed to remove service ${SERVICE_NAME}"
        docker::await_service_destroy "${SERVICE_NAME}"
    fi
    overwrite "Waiting for service $SERVICE_NAME to be removed ... Done"
}

# Tries to remove volumes and retries until it works with a timeout
#
# Arguments:
# - $1 : volumes names, e.g. "es-data" "psql-1" ..
#
docker::try_remove_volume() {
    if [[ -z "$*" ]]; then
        log error "FATAL: try_remove_volume parameter missing"
        exit 1
    fi

    for i in "$@"; do
        local -r volume_name=${i}

        if ! docker volume ls | grep -q "\sinstant_${volume_name}$"; then
            log info "Tried to remove volume ${volume_name} but it doesn't exist on this node"
            return 1
        fi

        log info "Waiting for volume ${volume_name} to be removed..."
        local start_time
        start_time=$(date +%s)
        until [[ -n "$(docker volume rm instant_"${volume_name}" 2>/dev/null)" ]]; do
            config::timeout_check "${start_time}" "${volume_name} to be removed" "60" "10"
            sleep 1
        done
        overwrite "Waiting for volume ${volume_name} to be removed... Done"
    done
}

# Prunes configs based on a label
#
# Arguments:
# - $1 : config label, e.g. "logstash"
#
docker::prune_configs() {
    local -r CONFIG_LABEL=${1:?"FATAL: remove_configs_by_label CONFIG_LABEL not provided"}

    # shellcheck disable=SC2046
    if [[ -n $(docker config ls -qf label=name="$CONFIG_LABEL") ]]; then
        log info "Waiting for configs to be removed..."

        docker config rm $(docker config ls -qf label=name="$CONFIG_LABEL") &>/dev/null

        overwrite "Waiting for configs to be removed... Done"
    fi
}

# Deploy a service, it will set config digests (in case a config is defined in the compose file)
#
# Arguments:
# - $1 : docker compose path, e.g. "/instant/monitoring" ...
# - $2 : docker compose file, e.g. "docker-compose.yml" "docker-compose.cluster.yml" ...
# - $3 : docker compose dev file, e.g. "docker-compose.dev.yml"
# - $4 : services names, e.g. "monitoring" "hapi-fhir" ...
#
docker::deploy_service() {
    local -r DOCKER_COMPOSE_PATH="${1:?"FATAL: function 'deploy_service' is missing a parameter"}"
    local -r DOCKER_COMPOSE_FILE="${2:?"FATAL: function 'deploy_service' is missing a parameter"}"
    local -r DOCKER_COMPOSE_DEV_FILE="${3:-""}"
    local docker_compose_dev=""

    # Check for need to set config digests
    local -r files=($(yq '.configs."*.*".file' "${DOCKER_COMPOSE_PATH}/$DOCKER_COMPOSE_FILE"))
    if [[ "${files[*]}" != "null" ]]; then
        config::set_config_digests "${DOCKER_COMPOSE_PATH}/$DOCKER_COMPOSE_FILE"
    fi

    if [[ -n "${DOCKER_COMPOSE_DEV_FILE}" ]]; then
        docker_compose_dev="-c ${DOCKER_COMPOSE_PATH}/$DOCKER_COMPOSE_DEV_FILE"
    fi

    try "docker stack deploy \
        -c ${DOCKER_COMPOSE_PATH}/$DOCKER_COMPOSE_FILE \
        $docker_compose_dev \
         instant" \
        throw \
        "Wrong configuration in ${DOCKER_COMPOSE_PATH}/$DOCKER_COMPOSE_FILE"
}

# Deploy a config importer:
# Sets the config digests, deploy the config importer, remove it and remove the stale configs
#
# Arguments:
# - $1 : docker compose path, e.g. "/instant/monitoring/importer/docker-compose.config.yml" ...
# - $2 : services name, e.g. "clickhouse-config-importer" ...
# - $3 : config label, e.g. "clickhouse" "kibana" ...
# - $4 : docker compose file name, default "docker-compose.config.yml"
#
docker::deploy_config_importer() {
    local -r CONFIG_COMPOSE_PATH="${1:?"FATAL: function 'deploy_config_importer' is missing a parameter"}"
    local -r SERVICE_NAME="${2:?"FATAL: function 'deploy_config_importer' is missing a parameter"}"
    local -r CONFIG_LABEL="${3:?"FATAL: function 'deploy_config_importer' is missing a parameter"}"

    log info "Waiting for config importer $SERVICE_NAME to start ..."
    (
        if [[ ! -f "$CONFIG_COMPOSE_PATH" ]]; then
            log error "No such file: $CONFIG_COMPOSE_PATH"
            exit 1
        fi

        config::set_config_digests "$CONFIG_COMPOSE_PATH"

        try \
            "docker stack deploy -c ${CONFIG_COMPOSE_PATH} instant" \
            throw \
            "Wrong configuration in $CONFIG_COMPOSE_PATH"

        log info "Waiting to give core config importer time to run before cleaning up service"

        config::remove_config_importer "$SERVICE_NAME"
        config::await_service_removed "instant_$SERVICE_NAME"

        log info "Removing stale configs..."
        config::remove_stale_service_configs "$CONFIG_COMPOSE_PATH" "$CONFIG_LABEL"
        overwrite "Removing stale configs... Done"
    ) || {
        log error "Failed to deploy the config importer: $SERVICE_NAME"
        exit 1
    }
}

# Check for errors when deploying
#
# Arguments:
# - $1 : service names, e.g. "monitoring" "hapi-fhir" ...
#
docker::deploy_sanity() {
    if [[ -z "$*" ]]; then
        log error "FATAL: deploy_sanity parameter missing"
        exit 1
    fi

    for i in "$@"; do
        log info "Waiting for $i to run ..."
        local start_time
        start_time=$(date +%s)

        error_message=()
        until [[ $(docker service ps instant_"$i" --format "{{.CurrentState}}" 2>/dev/null) == *"Running"* ]]; do
            config::timeout_check "${start_time}" "$i to run"
            sleep 1

            # Get unique error messages using sort -u
            new_error_message=($(docker service ps instant_"$i" --no-trunc --format '{{ .Error }}' 2>&1 | sort -u))
            if [[ -n ${new_error_message[*]} ]]; then
                # To prevent logging the same error
                if [[ "${error_message[*]}" != "${new_error_message[*]}" ]]; then
                    error_message=(${new_error_message[*]})
                    log error "Deploy error in service $i: ${error_message[*]}"
                fi
                # To exit in case the error is not having the image
                if [[ "${new_error_message[*]}" == *"No such image"* ]]; then
                    log error "Do you have access to pull the image?"
                    exit 124
                fi
            fi
        done
        overwrite "Waiting for $i to run ... Done"
    done
}

# An aggregate function to do multiple service ready checks in one function
#
# Arguments:
# - $1 : service name (eg. analytics-datastore-elastic-search)
#
docker::await_service_ready() {
    local -r SERVICE_NAME=${1:?"FATAL: await_service_ready SERVICE_NAME not provided"}

    docker::await_container_startup "$SERVICE_NAME"
    docker::await_container_status "$SERVICE_NAME" Running
    config::await_network_join instant_"$SERVICE_NAME"
}
