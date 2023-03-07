#!/bin/bash
#
# Library name: docker
# This is a library that contains functions to assist with docker actions

. "$(pwd)/utils/config-utils.sh"
. "$(pwd)/utils/log.sh"

# Gets current status of the provided service
#
# Arguments:
# - $1 : service name (eg. analytics-datastore-elastic-search)
# - $2 : (optional) stack name that service falls under (defaults to 'instant')
#
docker::get_current_service_status() {
    local -r SERVICE_NAME=${1:?$(missing_param "get_current_service_status")}
    local -r STACK_NAME=${2:-"instant"}

    docker service ps "${STACK_NAME}"_"${SERVICE_NAME}" --format "{{.CurrentState}}" 2>/dev/null
}

# Gets unique errors from the provided service
#
# Arguments:
# - $1 : service name (eg. analytics-datastore-elastic-search)
# - $2 : (optional) stack name that service falls under (defaults to 'instant')
#
docker::get_service_unique_errors() {
    local -r SERVICE_NAME=${1:?$(missing_param "get_service_unique_errors")}
    local -r STACK_NAME=${2:-"instant"}

    # Get unique error messages using sort -u
    docker service ps "${STACK_NAME}"_"${SERVICE_NAME}" --no-trunc --format '{{ .Error }}' 2>&1 | sort -u
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
# - $3 : (optional) stack name that service falls under (defaults to 'instant')
#
docker::await_service_status() {
    local -r SERVICE_NAME=${1:?$(missing_param "await_service_status" "SERVICE_NAME")}
    local -r SERVICE_STATUS=${2:?$(missing_param "await_service_status" "SERVICE_STATUS")}
    local -r STACK_NAME=${3:-"instant"}
    local -r start_time=$(date +%s)
    local error_message=()

    log info "Waiting for ${SERVICE_NAME} to be ${SERVICE_STATUS}..."
    until [[ $(docker::get_current_service_status "${SERVICE_NAME}" "${STACK_NAME}") == *"${SERVICE_STATUS}"* ]]; do
        config::timeout_check "${start_time}" "${SERVICE_NAME} to start"
        sleep 1

        # Get unique error messages using sort -u
        new_error_message=($(docker::get_service_unique_errors "$SERVICE_NAME" "$STACK_NAME"))
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
# - $2 : (optional) stack name that the service falls under (defaults to 'instant')
#
docker::await_service_destroy() {
    local -r SERVICE_NAME=${1:?$(missing_param "await_service_destroy")}
    local -r STACK_NAME="${2:-"instant"}"

    local start_time
    start_time=$(date +%s)
    while docker service ls | grep -q "\s${STACK_NAME}_${SERVICE_NAME}\s"; do
        config::timeout_check "${start_time}" "${SERVICE_NAME} to be destroyed"
        sleep 1
    done
}

# Removes services containers then the service itself
# This was created to aid in removing volumes,
# since volumes being removed were still attached to some lingering containers after container remove
#
# NB: Global services can't be scale down
#
# Arguments:
# - $@ : service names list (eg. analytics-datastore-elastic-search)
#
docker::service_destroy() {
    if [[ -z "$*" ]]; then
        log error "$(missing_param "await_service_destroy")"
        exit 1
    fi

    for service_name in "$@"; do
        log info "Waiting for service $service_name to be removed ... "
        if [[ -n $(docker service ls -qf name=instant_"${service_name}") ]]; then
            if [[ $(docker service ls --format "{{.Mode}}" -f name=instant_"${service_name}") != "global" ]]; then
                try "docker service scale instant_${service_name}=0" catch "Failed to scale down ${service_name}"
            fi
            try "docker service rm instant_${service_name}" catch "Failed to remove service ${service_name}"
            docker::await_service_destroy "${service_name}"
        fi
        overwrite "Waiting for service $service_name to be removed ... Done"
    done
}

# Removes the stack and awaits for each service in the stack to be removed
#
# Arguments:
# - $1 : stack name to be removed
# - $@ : service names list (eg. analytics-datastore-elastic-search)
#
docker::stack_destroy() {
    local -r STACK_NAME=${1:?$(missing_param "stack_destroy")}
    shift
    log info "Waiting for stack $STACK_NAME to be removed ..."
    try "docker stack rm \
        $STACK_NAME" \
        throw \
        "Failed to remove $STACK_NAME"
    overwrite "Waiting for stack $STACK_NAME to be removed ... Done"
    
    for service_name in "$@"; do
        log info "Waiting for service $service_name to be removed ... "
        if [[ -n $(docker service ls -qf name="${STACK_NAME}"_"${service_name}") ]]; then
            docker::await_service_destroy "${service_name}" "${STACK_NAME}"
        fi
        overwrite "Waiting for service $service_name to be removed ... Done"
    done
}

# Tries to remove volumes and retries until it works with a timeout
#
# Arguments:
# - $1 : (optional) stack name that the service falls under (requires the prefix stack=, eg. stack=openhim) (defaults to instant)
# - $@ : volumes names (eg. es-data psql-1)
#
docker::try_remove_volume() {
    local STACK_NAME="instant"
    if [[ $1 == stack=* ]]; then
        STACK_NAME=${1#stack=}
        shift
    fi

    if [[ -z "$*" ]]; then
        log error "$(missing_param "try_remove_volume")"
        exit 1
    fi

    for volume_name in "$@"; do
        if ! docker volume ls | grep -q "\s${STACK_NAME}_${volume_name}$"; then
            log warn "Tried to remove volume ${volume_name} but it doesn't exist on this node"
        else
            log info "Waiting for volume ${volume_name} to be removed..."
            local start_time
            start_time=$(date +%s)
            until [[ -n "$(docker volume rm "${STACK_NAME}"_"${volume_name}" 2>/dev/null)" ]]; do
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
# - $@ : configs label list (eg. logstash)
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

# Checks if the image exists, if not it will pull it from docker
#
# Arguments:
# - $@ : images list (eg. bitnami/kafka:3.3.1)
#
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

# Deploys a service
# It will pull images if they don't exist in the local docker hub registry
# It will set config digests (in case a config is defined in the compose file)
# It will remove stale configs
#
# Arguments:
# - $1 : docker compose path (eg. /instant/monitoring)
# - $2 : docker compose file (eg. docker-compose.yml docker-compose.cluster.yml)
# - $3 : (optional) docker compose dev file (eg. docker-compose.dev.yml)
# - $4 : (optional) docker compose dev mount file (eg. docker-compose.dev-mount.yml)
# - $5 : (optional) docker compose temp file (eg. docker-compose.tmp.yml)
# - $6 : (optional) docker stack name to group the service under (defaults to 'instant')
#
docker::deploy_service() {
    local -r DOCKER_COMPOSE_PATH="${1:?$(missing_param "deploy_service" "DOCKER_COMPOSE_PATH")}"
    local -r DOCKER_COMPOSE_FILE="${2:?$(missing_param "deploy_service" "DOCKER_COMPOSE_FILE")}"
    local -r DOCKER_COMPOSE_DEV_FILE="${3:-""}"
    local -r DOCKER_COMPOSE_DEV_MOUNT="${4:-""}"
    local -r DOCKER_COMPOSE_TEMP="${5:-""}"
    local -r DOCKER_COMPOSE_STACKNAME="${6:-"instant"}"
    local docker_compose_param=""

    docker::ensure_external_networks_existence "$DOCKER_COMPOSE_PATH/$DOCKER_COMPOSE_FILE"

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
        --with-registry-auth \
        ${DOCKER_COMPOSE_STACKNAME}" \
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

# Deploys a config importer
# Sets the config digests, deploys the config importer, removes it and removes the stale configs
#
# Arguments:
# - $1 : docker compose path (eg. /instant/monitoring/importer/docker-compose.config.yml)
# - $2 : services name (eg. clickhouse-config-importer)
# - $3 : config label (eg. clickhouse kibana)
# - $4 : (optional) stack name that the service falls under (defaults to 'instant')
#
docker::deploy_config_importer() {
    local -r CONFIG_COMPOSE_PATH="${1:?$(missing_param "deploy_config_importer" "CONFIG_COMPOSE_PATH")}"
    local -r SERVICE_NAME="${2:?$(missing_param "deploy_config_importer" "SERVICE_NAME")}"
    local -r CONFIG_LABEL="${3:?$(missing_param "deploy_config_importer" "CONFIG_LABEL")}"
    local -r STACK_NAME="${4:-"instant"}"

    log info "Waiting for config importer $SERVICE_NAME to start ..."
    (
        if [[ ! -f "$CONFIG_COMPOSE_PATH" ]]; then
            log error "No such file: $CONFIG_COMPOSE_PATH"
            exit 1
        fi

        config::set_config_digests "$CONFIG_COMPOSE_PATH"

        try \
            "docker stack deploy -c ${CONFIG_COMPOSE_PATH} ${STACK_NAME}" \
            throw \
            "Wrong configuration in $CONFIG_COMPOSE_PATH"

        log info "Waiting to give core config importer time to run before cleaning up service"

        config::remove_config_importer "$SERVICE_NAME" "$STACK_NAME"
        config::await_service_removed "$SERVICE_NAME" "$STACK_NAME"

        log info "Removing stale configs..."
        config::remove_stale_service_configs "$CONFIG_COMPOSE_PATH" "$CONFIG_LABEL"
        overwrite "Removing stale configs... Done"
    ) || {
        log error "Failed to deploy the config importer: $SERVICE_NAME"
        exit 1
    }
}

# Checks for errors when deploying
#
# Arguments:
# - $1 : (optional) stack name that the service falls under (requires the prefix stack=, eg. stack=openhim) (defaults to instant)
# - $@ : service names (eg. "monitoring" "hapi-fhir")
#
docker::deploy_sanity() {
    local STACK_NAME="instant"
    if [[ $1 == stack=* ]]; then
        STACK_NAME=${1#stack=}
        shift
    fi

    if [[ -z "$*" ]]; then
        log error "$(missing_param "deploy_sanity")"
        exit 1
    fi

    for service_name in "$@"; do
        docker::await_service_status "$service_name" "Running" "$STACK_NAME"
    done
}

# Does multiple service ready checks in one function
#
# Arguments:
# - $1 : service name (eg. analytics-datastore-elastic-search)
#
docker::await_service_ready() {
    local -r SERVICE_NAME=${1:?$(missing_param "await_service_ready")}

    docker::await_container_startup "$SERVICE_NAME"
    docker::await_service_status "$SERVICE_NAME" "Running"
    config::await_network_join instant_"$SERVICE_NAME"
}

# Scales down services
#
# Arguments:
# - $1 : (optional) stack name that the service falls under (requires the prefix stack=, eg. stack=openhim) (defaults to instant)
# - $@ : service names (eg. analytics-datastore-elastic-search)
#
docker::scale_services_down() {
    local STACK_NAME="instant"
    if [[ $1 == stack=* ]]; then
        STACK_NAME=${1#stack=}
        shift
    fi

    if [[ -z "$*" ]]; then
        log error "$(missing_param "scale_services_down")"
        exit 1
    fi

    for service_name in "$@"; do
        log info "Waiting for $service_name to scale down ..."
        try \
            "docker service scale "$STACK_NAME"_$service_name=0" \
            catch \
            "Failed to scale down $service_name"
        overwrite "Waiting for $service_name to scale down ... Done"
    done
}

# Scales up services
#
# Arguments:
# - $1 : replicas number (eg. 1)
# - $@ : service names list (eg. analytics-datastore-elastic-search)
#
docker::scale_services_up() {
    local -r REPLICAS="${1:?$(missing_param "scale_services_up" "REPLICAS")}"
    # Use shift to be able to get the array of services
    shift
    if [[ -z "$*" ]]; then
        log error "$(missing_param "scale_services_up" "SERVICES_NAME")"
        exit 1
    fi

    for service_name in "${@}"; do
        log info "Waiting for $service_name to scale up ..."
        try \
            "docker service scale instant_$service_name=$REPLICAS" \
            catch \
            "Failed to scale up $service_name"
        overwrite "Waiting for $service_name to scale up ... Done"
    done
}

# Checks if the external networks exist and tries create it if not
#
# Arguments:
# - $1 : path to the docker compose file with the network definitions
#
docker::ensure_external_networks_existence() {
    if [[ -z "$1" ]]; then
        log error "$(missing_param "ensure_external_networks_existence")"
        exit 1
    fi

    local -r network_keys=$(yq '.networks | keys' $1)
    local -r networks=(${network_keys//- /})
    if [[ "${networks[*]}" != "null" ]]; then
        for network_name in "${networks[@]}"; do
        # check if the property external is both present and set to true for the current network
        # then pull the necessary properties to create the network
        if [[ $(name=$network_name yq '.networks.[env(name)] | select(has("external")) | .external' $1) == true ]]; then
            local name=$(name=$network_name yq '.networks.[env(name)] | .name' $1)
            if [[ $name == "null" ]]; then
                name=$network_name
            fi
            
            # network with the name already exists so no need to create it
            if docker network ls | grep -q "\s$name\s"; then
                continue
            fi

            local driver=$(name=$network_name yq '.networks.[env(name)] | .driver' $1)
            if [[ $driver == "null" ]]; then
                driver="overlay"
            fi

            local attachable=""
            if [[ $(name=$network_name yq '.networks.[env(name)] | .attachable' $1) == true ]]; then
                attachable="--attachable"
            fi

            log info "Waiting to create external network $name ..."
            try \
                "docker network create --scope=swarm \
                -d $driver \
                $attachable \
                $name" \
                throw \
                "Failed to create network $name"
            overwrite "Waiting to create external network $name ... Done"
        fi
        done
    fi
}
