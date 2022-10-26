#!/bin/bash

readonly ACTION=$1

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)
readonly COMPOSE_FILE_PATH

# Import libraries
ROOT_PATH="${COMPOSE_FILE_PATH}/.."
. "${ROOT_PATH}/utils/config-utils.sh"
. "${ROOT_PATH}/utils/docker-utils.sh"
. "${ROOT_PATH}/utils/log.sh"

main() {
  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    if [[ ! -f "${COMPOSE_FILE_PATH}/config.ini" ]]; then
      log error "config.ini file does not exist! Aborting!!!"
      exit 1
    fi

    config::substitute_env_vars "${COMPOSE_FILE_PATH}"/config.ini
    config::set_config_digests "${COMPOSE_FILE_PATH}"/docker-compose.yml
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml instant" "Failed to deploy Job Scheduler Ofelia, does your .env file include all environment variables in your config.ini file?"
  elif [[ "${ACTION}" == "down" ]]; then
    try "docker service scale instant_job-scheduler-ofelia=0" "Failed to scale down job-scheduler-ofelia"
  elif [[ "${ACTION}" == "destroy" ]]; then
    docker::service_destroy job-scheduler-ofelia

    docker::prune_configs "ofelia"
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
