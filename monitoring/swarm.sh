#!/bin/bash

# Constants
readonly ACTION=$1
readonly MODE=$2
COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)

# Import libraries
ROOT_PATH="${COMPOSE_FILE_PATH}/.."
. "${ROOT_PATH}/utils/log.sh"

readonly GF_SECURITY_ADMIN_USER=${GF_SECURITY_ADMIN_USER:-"admin"}
readonly GF_SECURITY_ADMIN_PASSWORD=${GF_SECURITY_ADMIN_PASSWORD:-"dev_password_only"}

if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
  monitoring_dev_compose_param=""
  if [[ "${MODE}" == "dev" ]]; then
    monitoring_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
  fi

  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml ${monitoring_dev_compose_param} instant" "Failed to deploy monitoring stack"
elif [[ "${ACTION}" == "down" ]]; then
  log error "Not implemented"
elif [[ "${ACTION}" == "destroy" ]]; then
  log error "Not implemented"
else
  log error "Valid options are: init, up, down, or destroy"
fi
