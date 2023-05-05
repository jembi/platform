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
#
docker::get_current_service_status() {
    local -r SERVICE_NAME=${1:?$(missing_param "get_current_service_status")}
    docker service ps "${SERVICE_NAME}" --format "{{.CurrentState}}" 2>/dev/null
}

# Gets unique errors from the provided service
#
# Arguments:
# - $1 : service name (eg. analytics-datastore-elastic-search)
#
docker::get_service_unique_errors() {
    local -r SERVICE_NAME=${1:?$(missing_param "get_service_unique_errors")}

    # Get unique error messages using sort -u
    docker service ps "${SERVICE_NAME}" --no-trunc --format '{{ .Error }}' 2>&1 | sort -u
}

# Waits for a container to be up
#
# Arguments:
# - $1 : stack name that the service falls under (eg. elastic)
# - $2 : service name (eg. analytics-datastore-elastic-search)
#
docker::await_container_startup() {
    local -r STACK_NAME=${1:?$(missing_param "await_container_startup", "STACK_NAME")}
    local -r SERVICE_NAME=${2:?$(missing_param "await_container_startup", "SERVICE_NAME")}

    log info "Waiting for ${SERVICE_NAME} to start up..."
    local start_time
    start_time=$(date +%s)
    until [[ -n $(docker service ls -qf name="${STACK_NAME}"_"${SERVICE_NAME}") ]]; do
        config::timeout_check "${start_time}" "${SERVICE_NAME} to start"
        sleep 1
    done
    overwrite "Waiting for ${SERVICE_NAME} to start up... Done"
}

# Waits for a container to be up
#
# Arguments:
# - $1 : stack name that the service falls under (eg. elastic)
# - $2 : service name (eg. analytics-datastore-elastic-search)
# - $3 : service status (eg. running)
#
docker::await_service_status() {
    local -r STACK_NAME=${1:?$(missing_param "await_service_status" "STACK_NAME")}
    local -r SERVICE_NAME=${2:?$(missing_param "await_service_status" "SERVICE_NAME")}
    local -r SERVICE_STATUS=${3:?$(missing_param "await_service_status" "SERVICE_STATUS")}
    local -r start_time=$(date +%s)
    local error_message=()

    log info "Waiting for ${STACK_NAME}_${SERVICE_NAME} to be ${SERVICE_STATUS}..."
    until [[ $(docker::get_current_service_status ${STACK_NAME}_${SERVICE_NAME}) == *"${SERVICE_STATUS}"* ]]; do
        config::timeout_check "${start_time}" "${STACK_NAME}_${SERVICE_NAME} to start"
        sleep 1

        # Get unique error messages using sort -u
        new_error_message=($(docker::get_service_unique_errors ${STACK_NAME}_$SERVICE_NAME))
        if [[ -n ${new_error_message[*]} ]]; then
            # To prevent logging the same error
            if [[ "${error_message[*]}" != "${new_error_message[*]}" ]]; then
                error_message=(${new_error_message[*]})
                log error "Deploy error in service ${STACK_NAME}_$SERVICE_NAME: ${error_message[*]}"
            fi

            # To exit in case the error is not having the image
            if [[ "${new_error_message[*]}" == *"No such image"* ]]; then
                log error "Do you have access to pull the image?"
                exit 124
            fi
        fi
    done
    overwrite "Waiting for ${STACK_NAME}_${SERVICE_NAME} to be ${SERVICE_STATUS}... Done"
}

# Waits for a container to be destroyed
#
# Arguments:
# - $1 : stack name that the service container falls under (eg. elastic)
# - $2 : service name (eg. analytics-datastore-elastic-search)
#
docker::await_container_destroy() {
    local -r STACK_NAME=${1:?$(missing_param "await_container_destroy", "STACK_NAME")}
    local -r SERVICE_NAME=${2:?$(missing_param "await_container_destroy", "SERVICE_NAME")}

    log info "Waiting for ${STACK_NAME}_${SERVICE_NAME} to be destroyed..."
    local start_time
    start_time=$(date +%s)
    until [[ -z $(docker ps -qlf name="${STACK_NAME}_${SERVICE_NAME}") ]]; do
        config::timeout_check "${start_time}" "${SERVICE_NAME} to be destroyed"
        sleep 1
    done
    overwrite "Waiting for ${STACK_NAME}_${SERVICE_NAME} to be destroyed... Done"
}

# Waits for a service to be destroyed
#
# Arguments:
# - $1 : service name (eg. analytics-datastore-elastic-search)
# - $2 : stack name that the service falls under (eg. elastic)
#
docker::await_service_destroy() {
    local -r SERVICE_NAME=${1:?$(missing_param "await_service_destroy", "SERVICE_NAME")}
    local -r STACK_NAME=${2:?$(missing_param "await_service_destroy", "STACK_NAME")}
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
# - $1 : stack name that the services fall under (eg. elasticsearch)
# - $@ : service names list (eg. analytics-datastore-elastic-search)
#
docker::service_destroy() {
    local -r STACK_NAME=${1:?$(missing_param "service_destroy", "STACK_NAME")}
    shift

    if [[ -z "$*" ]]; then
        log error "$(missing_param "service_destroy", "[SERVICE_NAMES]")"
        exit 1
    fi

    for service_name in "$@"; do
        local service="${STACK_NAME}"_$service_name
        log info "Waiting for service $service to be removed ... "
        if [[ -n $(docker service ls -qf name=$service) ]]; then
            if [[ $(docker service ls --format "{{.Mode}}" -f name=$service) != "global" ]]; then
                try "docker service scale $service=0" catch "Failed to scale down ${service_name}"
            fi
            try "docker service rm $service" catch "Failed to remove service ${service_name}"
            docker::await_service_destroy "$service_name" "$STACK_NAME"
        fi
        overwrite "Waiting for service $service_name to be removed ... Done"
    done
}

# Removes the stack and awaits for each service in the stack to be removed
#
# Arguments:
# - $1 : stack name to be removed
#
docker::stack_destroy() {
    local -r STACK_NAME=${1:?$(missing_param "stack_destroy")}
    log info "Waiting for stack $STACK_NAME to be removed ..."
    try "docker stack rm \
        $STACK_NAME" \
        throw \
        "Failed to remove $STACK_NAME"

    local start_time=$(date +%s)
    while [[ -n "$(docker stack ps $STACK_NAME 2>/dev/null)" ]] ; do
        config::timeout_check "${start_time}" "${STACK_NAME} to be destroyed"
        sleep 1
    done

    overwrite "Waiting for stack $STACK_NAME to be removed ... Done"

    log info "Pruning networks ... "
    try "docker network prune -f" catch "Failed to prune networks"
    overwrite "Pruning networks ... done"

    docker::prune_volumes
}

# Loops through all current services and builds up a dictionary of volume names currently in use
# (this also considers downed services, as you don't want to prune volumes for downed services)
# It then loops through all volumes and removes any that do not have a service definition attached to it
#
docker::prune_volumes() {
    # Create an associative array to act as the dictionary to hold service volume names
    # Need to add instant, which the gocli uses but is not defined as a service
    declare -A referenced_volumes=(['instant']=true)

    log info "Pruning volumes ... "

    for service in $(docker service ls -q); do
        for volume in $(docker service inspect $service --format '{{range .Spec.TaskTemplate.ContainerSpec.Mounts}}{{println .Source}}{{end}}'); do
            referenced_volumes[$volume]=true
        done
    done

    for volume in $(docker volume ls --format {{.Name}}); do
        # Check to see if the key (which is the volume name) exists
        if [[ -v referenced_volumes[$volume] ]]; then
            continue
        fi

        # Ignore volumes attached to a container but are not apart of a service definition
        local start_time=$(date +%s)
        local should_ignore=true
        if [[ -n $(docker ps -a -q --filter volume=$volume) ]]; then
            local timeDiff=$(($(date +%s) - $start_time))
            until [[ $timeDiff -ge 10 ]]; do
                timeDiff=$(($(date +%s) - $start_time))
                if [[ -n $(docker ps -a -q --filter volume=$volume) ]]; then 
                    sleep 1
                else
                    should_ignore=false
                fi
            done
            if $should_ignore; then
                continue
            fi
        fi

        log info "Waiting for volume $volume to be removed..."
        start_time=$(date +%s)
        until [[ -z "$(docker volume ls -q --filter name=^$volume$ 2>/dev/null)" ]]; do
            docker volume rm $volume >/dev/null 2>&1
            config::timeout_check "${start_time}" "$volume to be removed" "60" "10"
            sleep 1
        done
        overwrite "Waiting for volume $volume to be removed... Done"
    done

    overwrite "Pruning volumes ... done"
}

# Prunes configs based on a label
#
# Arguments:
# - $@ : configs label list (eg. logstash)
#
docker::prune_configs() {
    if [[ -z "$*" ]]; then
        log error "$(missing_param "prune_configs", "[CONFIG_LABELS]")"
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
        log error "$(missing_param "check_images_existence", "[IMAGES]")"
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
# - $1 : docker stack name to group the service under
# - $2 : docker compose path (eg. /instant/monitoring)
# - $3 : docker compose file (eg. docker-compose.yml or docker-compose.cluster.yml)
# - $@ : (optional) list of docker compose files (eg. docker-compose.cluster.yml docker-compose.dev.yml)
# - $@:4:n : (optional) a marker 'defer-sanity' used to defer deploy::sanity to the caller, can appear anywhere in the optional list 
#
docker::deploy_service() {
    local -r STACK_NAME="${1:?$(missing_param "deploy_service" "STACK_NAME")}"
    local -r DOCKER_COMPOSE_PATH="${2:?$(missing_param "deploy_service" "DOCKER_COMPOSE_PATH")}"
    local -r DOCKER_COMPOSE_FILE="${3:?$(missing_param "deploy_service" "DOCKER_COMPOSE_FILE")}"
    local docker_compose_param=""

    # Check for the existance of the images
    local -r images=($(yq '.services."*".image' "${DOCKER_COMPOSE_PATH}/$DOCKER_COMPOSE_FILE"))
    if [[ "${images[*]}" != "null" ]]; then
        docker::check_images_existence "${images[@]}"
    fi

    local defer_sanity=false
    for optional_config in "${@:4}"; do
        if [[ -n $optional_config ]]; then
            if [[ $optional_config == "defer-sanity" ]]; then
                defer_sanity=true
            else
                docker_compose_param="$docker_compose_param -c ${DOCKER_COMPOSE_PATH}/$optional_config"
            fi
        fi
    done

    docker::prepare_config_digests "$DOCKER_COMPOSE_PATH/$DOCKER_COMPOSE_FILE" ${docker_compose_param//-c /}
    docker::ensure_external_networks_existence "$DOCKER_COMPOSE_PATH/$DOCKER_COMPOSE_FILE" ${docker_compose_param//-c /}

    try "docker stack deploy \
        -c ${DOCKER_COMPOSE_PATH}/$DOCKER_COMPOSE_FILE \
        $docker_compose_param \
        --with-registry-auth \
        ${STACK_NAME}" \
        throw \
        "Wrong configuration in ${DOCKER_COMPOSE_PATH}/$DOCKER_COMPOSE_FILE or in the other supplied compose files"

    docker::cleanup_stale_configs "$DOCKER_COMPOSE_PATH/$DOCKER_COMPOSE_FILE" ${docker_compose_param//-c /}

    if [[ $defer_sanity != true ]]; then
        docker::deploy_sanity "$STACK_NAME" "$DOCKER_COMPOSE_PATH/$DOCKER_COMPOSE_FILE" ${docker_compose_param//-c /}
    fi
}

# Deploys a config importer
# Sets the config digests, deploys the config importer, removes it and removes the stale configs
#
# Arguments:
# - $1 : stack name that the service falls under
# - $2 : docker compose path (eg. /instant/monitoring/importer/docker-compose.config.yml)
# - $3 : services name (eg. clickhouse-config-importer)
# - $4 : config label (eg. clickhouse kibana)
#
docker::deploy_config_importer() {
    local -r STACK_NAME="${1:?$(missing_param "deploy_config_importer" "STACK_NAME")}"
    local -r CONFIG_COMPOSE_PATH="${2:?$(missing_param "deploy_config_importer" "CONFIG_COMPOSE_PATH")}"
    local -r SERVICE_NAME="${3:?$(missing_param "deploy_config_importer" "SERVICE_NAME")}"
    local -r CONFIG_LABEL="${4:?$(missing_param "deploy_config_importer" "CONFIG_LABEL")}"

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

        config::remove_config_importer "$STACK_NAME" "$SERVICE_NAME"
        config::await_service_removed "$STACK_NAME" "$SERVICE_NAME"

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
# - $1 : stack name that the services falls under
# - $@ : fully qualified path to the compose file(s) with service definitions (eg. /instant/interoperability-layer-openhim/docker-compose.yml)
#
docker::deploy_sanity() {
    local -r STACK_NAME="${1:?$(missing_param "deploy_sanity" "STACK_NAME")}"
    # shift off the stack name to get the subset of services to check  
    shift

    if [[ -z "$*" ]]; then
        log error "$(missing_param "deploy_sanity" "[COMPOSE_FILES]")"
        exit 1
    fi

    local services=()
    for compose_file in "$@"; do
    # yq 'keys' returns:"- foo - bar" if you have yml with a foo: and bar: service definition
    # which is why we remove the "- " before looping
    # it will also return '#' as a key if you have a comment, so we clean them with ' ... comments="" ' first
        local compose_services=$(yq '... comments="" | .services | keys' $compose_file)
        compose_services=${compose_services//- /}
        for service in ${compose_services[@]}; do
            # only append unique service to services
            if [[ ! ${services[*]} =~ $service ]]; then
                services+=($service)
            fi
        done
    done

    for service_name in ${services[@]}; do
        docker::await_service_status $STACK_NAME "$service_name" "Running"
    done
}

# Scales services to the passed in replica count
#
# Arguments:
# - $1 : stack name that the services falls under
# - $2 : replicas number (eg. 0 (to scale down) or 1 (to scale up) or 2 (to scale up more))
#
docker::scale_services() {
    local -r STACK_NAME="${1:?$(missing_param "scale_services" "STACK_NAME")}"
    local -r REPLICAS="${2:?$(missing_param "scale_services" "REPLICAS")}"
    local services=($(docker stack services $STACK_NAME | awk '{print $2}' | tail -n +2))
    for service_name in "${services[@]}"; do
        log info "Waiting for $service_name to scale to $REPLICAS ..."
        try \
            "docker service scale $service_name=$REPLICAS" \
            catch \
            "Failed to scale $service_name to $REPLICAS"
        overwrite "Waiting for $service_name to scale to $REPLICAS ... Done"
    done
}

# Checks if the external networks exist and tries to create them if they do not
#
# Arguments:
# - $@ : fully qualified path to the docker compose file(s) with the possible network definitions (eg. /instant/interoperability-layer-openhim/docker-compose.yml)
#
docker::ensure_external_networks_existence() {
    if [[ -z "$*" ]]; then
        log error "$(missing_param "ensure_external_networks_existence", "[COMPOSE_FILES]")"
        exit 1
    fi

    for compose_file in "$@"; do
        if [[ $(yq '.networks' $compose_file) == "null" ]]; then
            continue
        fi
        
        local network_keys=$(yq '... comments="" | .networks | keys' $compose_file)
        local networks=(${network_keys//- /})
        if [[ "${networks[*]}" != "null" ]]; then
            for network_name in "${networks[@]}"; do
                # check if the property external is both present and set to true for the current network
                # then pull the necessary properties to create the network
                if [[ $(name=$network_name yq '.networks.[env(name)] | select(has("external")) | .external' $compose_file) == true ]]; then
                    local name=$(name=$network_name yq '.networks.[env(name)] | .name' $compose_file)
                    if [[ $name == "null" ]]; then
                        name=$network_name
                    fi
                    
                    # network with the name already exists so no need to create it
                    if docker network ls | awk '{print $2}' | grep -q -w "$name"; then
                        continue
                    fi

                    local driver=$(name=$network_name yq '.networks.[env(name)] | .driver' $compose_file)
                    if [[ $driver == "null" ]]; then
                        driver="overlay"
                    fi

                    local attachable=""
                    if [[ $(name=$network_name yq '.networks.[env(name)] | .attachable' $compose_file) == true ]]; then
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
    done
}

# Joins a service to a network by updating the service spec to include the network.
#
# Note: Do not remove if not used in the Platform as this is mainly used by
# custom packages that cannot overwrite the docker compose file to add the network connection required.
#
# Arguments:
# - $1 : service name that needs to join the network (eg. analytics-datastore-elastic-search)
# - $2 : network name to join (eg. elastic_public)
#
docker::join_network() {
    local -r SERVICE_NAME="${1:?$(missing_param "join_network" "SERVICE_NAME")}"
    local -r NETWORK_NAME="${2:?$(missing_param "join_network" "NETWORK_NAME")}"
    local network_id
    network_id=$(docker network ls --filter name="$NETWORK_NAME$" --format '{{.ID}}')
    if [[ -n "${network_id}" ]]; then
        if docker service inspect "$SERVICE_NAME" --format "{{.Spec.TaskTemplate.Networks}}" | grep -q "$network_id"; then
            log info "Service $SERVICE_NAME is already connected to network $NETWORK_NAME."
        else
            log info "Waiting to join $SERVICE_NAME to external network $NETWORK_NAME ..."
            try \
                "docker service update  \
              --network-add name=$NETWORK_NAME \
              $SERVICE_NAME" \
                throw \
                "Failed to join network $NETWORK_NAME"
        fi
    else
        log error "Network $NETWORK_NAME does not exist, cannot join $SERVICE_NAME to it ..."
    fi
}

# Checks the compose file(s) passed in for the existance of a config.file definition to pass to config::set_config_digests
#
# Arguments:
# - $@ : fully qualified path to the compose file(s) to check (eg. /instant/interoperability-layer-openhim/docker-compose.yml)
#
docker::prepare_config_digests()
{
    if [[ -z "$*" ]]; then
        log error "$(missing_param "prepare_config_digests", "[COMPOSE_FILES]")"
        exit 1
    fi

    for compose_file in "$@"; do
        local files=($(yq '.configs."*.*".file' "$compose_file"))
        if [[ "${files[*]}" != "null" ]]; then
            config::set_config_digests "$compose_file"
        fi
    done
}

# Checks the compose file(s) passed in for the existance of a config.lables.name definition to pass to config::remove_stale_service_configs
# To ensure that the service has the most up to date config digest
#
# Arguments:
# - $@ : fully qualified path to the compose file(s) to check (eg. /instant/interoperability-layer-openhim/docker-compose.yml)
#
docker::cleanup_stale_configs()
{
    if [[ -z "$*" ]]; then
        log error "$(missing_param "cleanup_stale_configs", "[COMPOSE_FILES]")"
        exit 1
    fi

    for compose_file in "$@"; do
        local label_names=($(yq '.configs."*.*".labels.name' "$compose_file" | sort -u))
        if [[ "${label_names[*]}" != "null" ]]; then
            for label_name in "${label_names[@]}"; do
                config::remove_stale_service_configs "$compose_file" "${label_name}"
            done
        fi
    done
}
