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
    local start_time
    start_time=$(date +%s)
    until [[ $(docker service ps instant_"${SERVICE_NAME}" --format "{{.CurrentState}}" 2>/dev/null) == *"${SERVICE_STATUS}"* ]]; do
        config::timeout_check "${start_time}" "${SERVICE_NAME} to start"
        sleep 1
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
    until [[ -z $(docker service ls -qf name=instant_"${SERVICE_NAME}") ]]; do
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

    if [[ -n $(docker service ls -qf name=instant_"${SERVICE_NAME}") ]]; then
        try "docker service scale instant_${SERVICE_NAME}=0" "Failed to scale down ${SERVICE_NAME}"
        try "docker service rm instant_${SERVICE_NAME}" "Failed to remove service ${SERVICE_NAME}"
        docker::await_service_destroy "${SERVICE_NAME}"
    fi
}

# Tries to remove a volume and retries until it works with a timeout
#
# Arguments:
# - $1 : volume name (eg. es-data)
#
docker::try_remove_volume() {
    local -r VOLUME_NAME=${1:?"FATAL: remove_volume_retry VOLUME_NAME not provided"}

    log info "Waiting for volume ${VOLUME_NAME} to be removed..."
    local start_time
    start_time=$(date +%s)
    until [[ -n "$(docker volume rm instant_"${VOLUME_NAME}" 2>/dev/null)" ]]; do
        config::timeout_check "${start_time}" "${VOLUME_NAME} to be removed" "20" "10"
        sleep 1
    done
    overwrite "Waiting for volume ${VOLUME_NAME} to be removed... Done"
}

# Prunes configs based on a label
#
# Arguments:
# - $1 : config label, e.g. "logstash"
#
docker::prune_configs() {
    local -r CONFIG_LABEL=${1:?"FATAL: remove_configs_by_label CONFIG_LABEL not provided"}

    # shellcheck disable=SC2046
    docker config rm $(docker config ls -qf label=name="$CONFIG_LABEL") &>/dev/null
}
