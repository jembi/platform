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

. "${ROOT_PATH}/utils/docker-utils.sh"
. "${ROOT_PATH}/utils/log.sh"

main() {
  if [[ "${MODE}" == "dev" ]]; then
    log info "Running Analytics Datastore Clickhouse package in DEV mode"
    clickhouse_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
  else
    log info "Running Analytics Datastore Clickhouse package in PROD mode"
    clickhouse_dev_compose_param=""
  fi

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml $clickhouse_dev_compose_param instant" "Failed to deploy Analytics Datastore Clickhouse"

  elif [[ "${ACTION}" == "down" ]]; then
    try "docker service scale instant_analytics-datastore-clickhouse=0" "Failed to scale down analytics-datastore-clickhouse"
  elif [[ "${ACTION}" == "destroy" ]]; then
    docker::service_destroy analytics-datastore-clickhouse
    docker::try_remove_volume clickhouse-data
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
