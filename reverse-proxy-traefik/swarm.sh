#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare SERVICE_NAMES=()
declare STACK="traefik"

function init_vars() {
    ACTION=$1
    MODE=$2

    COMPOSE_FILE_PATH=$(
        cd "$(dirname "${BASH_SOURCE[0]}")" || exit
        pwd -P
    )

    UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

    SERVICE_NAMES=("reverse-proxy-traefik")

    readonly ACTION
    readonly MODE
    readonly COMPOSE_FILE_PATH
    readonly UTILS_PATH
    readonly SERVICE_NAMES
    readonly STACK
}

# shellcheck disable=SC1091
function import_sources() {
    source "${UTILS_PATH}/docker-utils.sh"
    source "${UTILS_PATH}/config-utils.sh"
    source "${UTILS_PATH}/log.sh"
}

function initialize_package() {

    log info "Running package in PROD mode"

    log info "Deploying package with compose file: ${COMPOSE_FILE_PATH}/docker-compose.yml"

    (
        docker::deploy_service $STACK "${COMPOSE_FILE_PATH}" "docker-compose.yml"
    ) || {
        log error "Failed to deploy package"
        exit 1
    }

}

function destroy_package() {
    docker::stack_destroy $STACK

    docker::prune_configs $STACK
}

main() {
    init_vars "$@"
    import_sources

    if [[ "${MODE}" == "dev" ]]; then
        log info "Not including reverse proxy as we are running DEV mode"
        exit 0
    fi

    if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
        log info "Running package"

        initialize_package
    elif [[ "${ACTION}" == "down" ]]; then
        log info "Scaling down package"

        docker::scale_services $STACK 0
    elif [[ "${ACTION}" == "destroy" ]]; then
        log info "Destroying package"
        destroy_package
    else
        log error "Valid options are: init, up, down, or destroy"
    fi
}

main "$@"
