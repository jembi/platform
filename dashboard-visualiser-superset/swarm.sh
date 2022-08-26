#!/bin/bash

readonly ACTION=$1
readonly MODE=$2

readonly STATEFUL_NODES=${STATEFUL_NODES:-"cluster"}

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)
readonly COMPOSE_FILE_PATH

ROOT_PATH="${COMPOSE_FILE_PATH}/.."
readonly ROOT_PATH

. "${ROOT_PATH}/utils/docker-utils.sh"
. "${ROOT_PATH}/utils/log.sh"

main() {
  if [[ "${MODE}" == "dev" ]]; then
    log info "Running Dashboard Visualiser Superset package in DEV mode"
    superset_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
  else
    log info "Running Dashboard Visualiser Superset package in PROD mode"
    superset_dev_compose_param=""
  fi

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml $superset_dev_compose_param instant" "Failed to deploy Dashboard Visualiser Superset"

  elif [[ "${ACTION}" == "down" ]]; then
    try "docker service scale instant_dashboard-visualiser-superset=0" "Failed to scale down dashboard-visualiser-superset"
  elif [[ "${ACTION}" == "destroy" ]]; then
    docker::service_destroy dashboard-visualiser-superset
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
