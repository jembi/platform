#!/bin/bash
#
# Library name: docker
# This is a library that contains functions to assist with docker actions

. "$(pwd)/utils/config-utils.sh"
. "$(pwd)/utils/log.sh"

# Get current status of the provided service
#
# Arguments:
# - $1 : service name (eg. analytics-datastore-elastic-search)
#
docker::get_current_service_status() {
    local -r SERVICE_NAME=${1:?$(missing_param "get_current_service_status")}

    docker service ps instant_"${SERVICE_NAME}" --format "{{.CurrentState}}" 2>/dev/null
}

# Get unique errors from the provided service
#
# Arguments:
# - $1 : service name (eg. analytics-datastore-elastic-search)
#
docker::get_service_unique_errors() {
    local -r SERVICE_NAME=${1:?$(missing_param "get_service_unique_errors")}

    # Get unique error messages using sort -u
    docker service ps instant_"${SERVICE_NAME}" --no-trunc --format '{{ .Error }}' 2>&1 | sort -u
}

# Waits for a container to be up
#
# Arguments:
# - $1 : service name (eg. analytics-datastore-elastic-search)
#
docker::await_container_startup() {
    local -r SERVICE_NAME=${1:?$(missing_param "await_container_startup")}

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
docker::await_service_status() {
    local -r SERVICE_NAME=${1:?$(missing_param "await_service_status" "SERVICE_NAME")}
    local -r SERVICE_STATUS=${2:?$(missing_param "await_service_status" "SERVICE_STATUS")}
    local -r start_time=$(date +%s)
    local error_message=()

    log info "Waiting for ${SERVICE_NAME} to be ${SERVICE_STATUS}..."
    until [[ $(docker::get_current_service_status "${SERVICE_NAME}") == *"${SERVICE_STATUS}"* ]]; do
        config::timeout_check "${start_time}" "${SERVICE_NAME} to start"
        sleep 1

        # Get unique error messages using sort -u
        new_error_message=($(docker::get_service_unique_errors "$SERVICE_NAME"))
        if [[ -n ${new_error_message[*]} ]]; then
            # To prevent logging the same error
            if [[ "${error_message[*]}" != "${new_error_message[*]}" ]]; then
                error_message=(${new_error_message[*]})
                log error "Deploy error in service $SERVICE_NAME: ${error_message[*]}"
            fi

            # To exit in case the error is not having the image
            if [[ "${new_error_message[*]}" == *"No such image"* ]]; then
                log error "Do you have access to pull the image?"
                exit 124
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
    local -r SERVICE_NAME=${1:?$(missing_param "await_container_destroy")}

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
    local -r SERVICE_NAME=${1:?$(missing_param "await_service_destroy")}

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
    if [[ -z "$*" ]]; then
        log error "$(missing_param "await_service_destroy")"
        exit 1
    fi

    for service_name in "$@"; do
        log info "Waiting for service $service_name to be removed ... "
        if [[ -n $(docker service ls -qf name=instant_"${service_name}") ]]; then
            try "docker service scale instant_${service_name}=0" catch "Failed to scale down ${service_name}"
            try "docker service rm instant_${service_name}" catch "Failed to remove service ${service_name}"
            docker::await_service_destroy "${service_name}"
        fi
        overwrite "Waiting for service $service_name to be removed ... Done"
    done
}

# Tries to remove volumes and retries until it works with a timeout
#
# Arguments:
# - $1 : volumes names, e.g. "es-data" "psql-1" ..
#
docker::try_remove_volume() {
    if [[ -z "$*" ]]; then
        log error "$(missing_param "try_remove_volume")"
        exit 1
    fi

    for volume_name in "$@"; do
        if ! docker volume ls | grep -q "\sinstant_${volume_name}$"; then
            log warn "Tried to remove volume ${volume_name} but it doesn't exist on this node"
        else
            log info "Waiting for volume ${volume_name} to be removed..."
            local start_time
            start_time=$(date +%s)
            until [[ -n "$(docker volume rm instant_"${volume_name}" 2>/dev/null)" ]]; do
                config::timeout_check "${start_time}" "${volume_name} to be removed" "60" "10"
                sleep 1
            done
            overwrite "Waiting for volume ${volume_name} to be removed... Done"
        fi
    done
}

# Prunes configs based on a label
#
# Arguments:
# - $1 : config label, e.g. "logstash"
#
docker::prune_configs() {
    if [[ -z "$*" ]]; then
        log error "$(missing_param "prune_configs")"
        exit 1
    fi

    for config_name in "$@"; do
        # shellcheck disable=SC2046
        if [[ -n $(docker config ls -qf label=name="$config_name") ]]; then
            log info "Waiting for configs to be removed..."

            docker config rm $(docker config ls -qf label=name="$config_name") &>/dev/null

            overwrite "Waiting for configs to be removed... Done"
        fi
    done
}

docker::check_images_existence() {
    if [[ -z "$*" ]]; then
        log error "$(missing_param "check_images_existence")"
        exit 1
    fi

    local timeout_pull_image
    timeout_pull_image=300
    for image_name in "$@"; do
        image_name=$(eval echo "$image_name")
        if [[ -z $(docker image inspect "$image_name" --format "{{.Id}}" 2>/dev/null) ]]; then
            log info "The image $image_name is not found, Pulling from docker..."
            try \
                "timeout $timeout_pull_image docker pull $image_name 1>/dev/null" \
                throw \
                "An error occured while pulling the image $image_name"

            overwrite "The image $image_name is not found, Pulling from docker... Done"
        fi
    done
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
    local -r DOCKER_COMPOSE_PATH="${1:?$(missing_param "deploy_service" "DOCKER_COMPOSE_PATH")}"
    local -r DOCKER_COMPOSE_FILE="${2:?$(missing_param "deploy_service" "DOCKER_COMPOSE_FILE")}"
    local -r DOCKER_COMPOSE_DEV_FILE="${3:-""}"
    local -r DOCKER_COMPOSE_DEV_MOUNT="${4:-""}"
    local -r DOCKER_COMPOSE_TEMP="${5:-""}"
    local docker_compose_param=""

    # Check for the existance of the images
    local -r images=($(yq '.services."*".image' "${DOCKER_COMPOSE_PATH}/$DOCKER_COMPOSE_FILE"))
    if [[ "${images[*]}" != "null" ]]; then
        docker::check_images_existence "${images[@]}"
    fi

    # Check for need to set config digests
    local -r files=($(yq '.configs."*.*".file' "${DOCKER_COMPOSE_PATH}/$DOCKER_COMPOSE_FILE"))
    if [[ "${files[*]}" != "null" ]]; then
        config::set_config_digests "${DOCKER_COMPOSE_PATH}/$DOCKER_COMPOSE_FILE"
    fi

    # Adding Dev compose file to the params
    if [[ -n "${DOCKER_COMPOSE_DEV_FILE}" ]]; then
        docker_compose_param="-c ${DOCKER_COMPOSE_PATH}/$DOCKER_COMPOSE_DEV_FILE"
    fi

    # Adding Dev mount compose file to the params
    if [[ -n "${DOCKER_COMPOSE_DEV_MOUNT}" ]]; then
        docker_compose_param="$docker_compose_param -c ${DOCKER_COMPOSE_PATH}/$DOCKER_COMPOSE_DEV_MOUNT"
    fi

    if [[ -n "${DOCKER_COMPOSE_TEMP}" ]]; then
        docker_compose_param="$docker_compose_param -c ${DOCKER_COMPOSE_PATH}/$DOCKER_COMPOSE_TEMP"
    fi

    try "docker stack deploy \
        -c ${DOCKER_COMPOSE_PATH}/$DOCKER_COMPOSE_FILE \
        $docker_compose_param \
         instant" \
        throw \
        "Wrong configuration in ${DOCKER_COMPOSE_PATH}/$DOCKER_COMPOSE_FILE or in the other supplied compose files"

    # Remove stale configs according to the labels in the compose file
    local -r label_names=($(yq '.configs."*.*".labels.name' "${DOCKER_COMPOSE_PATH}/${DOCKER_COMPOSE_FILE}" | sort -u))
    if [[ "${label_names[*]}" != "null" ]]; then
        for label_name in "${label_names[@]}"; do
            config::remove_stale_service_configs "$COMPOSE_FILE_PATH/$DOCKER_COMPOSE_FILE" "${label_name}"
        done
    fi
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
    local -r CONFIG_COMPOSE_PATH="${1:?$(missing_param "deploy_config_importer" "CONFIG_COMPOSE_PATH")}"
    local -r SERVICE_NAME="${2:?$(missing_param "deploy_config_importer" "SERVICE_NAME")}"
    local -r CONFIG_LABEL="${3:?$(missing_param "deploy_config_importer" "CONFIG_LABEL")}"

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
        log error "$(missing_param "deploy_sanity")"
        exit 1
    fi

    for service_name in "$@"; do
        docker::await_service_status "$service_name" "Running"
    done
}

# An aggregate function to do multiple service ready checks in one function
#
# Arguments:
# - $1 : service name (eg. analytics-datastore-elastic-search)
#
docker::await_service_ready() {
    local -r SERVICE_NAME=${1:?$(missing_param "await_service_ready")}

    docker::await_container_startup "$SERVICE_NAME"
    docker::await_service_status "$SERVICE_NAME" Running
    config::await_network_join instant_"$SERVICE_NAME"
}

# An function to scale down services
#
# Arguments:
# - $1 : service names (eg. analytics-datastore-elastic-search)
#
docker::scale_services_down() {
    if [[ -z "$*" ]]; then
        log error "$(missing_param "scale_services_down")"
        exit 1
    fi

    for service_name in "$@"; do
        try \
            "docker service scale instant_$service_name=0" \
            catch \
            "Failed to scale down $service_name"
    done
}
