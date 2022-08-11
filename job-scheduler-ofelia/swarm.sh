#!/bin/bash

readonly ACTION=$1

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

set_config_ini_env_vars() {
  local substituted_string
  substituted_string=$(envsubst <"${COMPOSE_FILE_PATH}"/config.ini)
  try "truncate -s 0 config.ini" "Failed to clear config.ini file"
  echo "$substituted_string" >"${COMPOSE_FILE_PATH}"/config.ini
}

main() {
  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    config::set_config_digests "${COMPOSE_FILE_PATH}"/docker-compose.yml

    set_config_ini_env_vars

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml instant" "Failed to deploy Job Scheduler Ofelia, does your .env file include all environment variables in your config.ini file?"
  elif [[ "${ACTION}" == "down" ]]; then
    try "docker service scale instant_job-scheduler-ofelia=0" "Failed to scale down job-scheduler-ofelia"
  elif [[ "${ACTION}" == "destroy" ]]; then
    docker::service_destroy job-scheduler-ofelia
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
