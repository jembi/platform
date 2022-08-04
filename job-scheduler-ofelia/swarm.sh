#!/bin/bash

readonly ACTION=$1

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
  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml instant" "Failed to deploy Job Scheduler Ofelia"
  elif [[ "${ACTION}" == "down" ]]; then
    try "docker service scale instant_job-scheduler-ofelia=0" "Failed to scale down job-scheduler-ofelia"
  elif [[ "${ACTION}" == "destroy" ]]; then
    docker::service_destroy job-scheduler-ofelia
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
