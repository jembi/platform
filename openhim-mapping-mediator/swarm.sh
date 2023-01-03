#!/bin/bash

readonly ACTION=$1
readonly MODE=$2

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)
readonly COMPOSE_FILE_PATH

ROOT_PATH="${COMPOSE_FILE_PATH}/.."
readonly ROOT_PATH

. "${ROOT_PATH}/utils/config-utils.sh"
. "${ROOT_PATH}/utils/docker-utils.sh"
. "${ROOT_PATH}/utils/log.sh"

main() {
  if [[ "${MODE}" == "dev" ]]; then
    log info "Running Openhim Mapping Mediator package in DEV mode"
    openhim_mapping_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
  else
    log info "Running Openhim Mapping Mediator package in PROD mode"
    openhim_mapping_dev_compose_param=""
  fi

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml $openhim_mapping_dev_compose_param instant" "Failed to deploy Openhim Mapping Mediator"

    docker::await_container_startup openhim-mapping-mediator
    docker::await_container_status openhim-mapping-mediator Running

    config::await_network_join "instant_openhim-mapping-mediator"

    docker::deploy_sanity openhim-mapping-mediator
  elif [[ "${ACTION}" == "down" ]]; then
    try "docker service scale instant_openhim-mapping-mediator=0" "Failed to scale down openhim-mapping-mediator"
  elif [[ "${ACTION}" == "destroy" ]]; then
    docker::service_destroy openhim-mapping-mediator
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
