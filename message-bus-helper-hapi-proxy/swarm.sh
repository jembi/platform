#!/bin/bash

readonly ACTION=$1
readonly MODE=$2
readonly HAPI_PROXY_INSTANCES=${HAPI_PROXY_INSTANCES:-1}
export HAPI_PROXY_INSTANCES

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)

# Import libraries
ROOT_PATH="${COMPOSE_FILE_PATH}/.."
. "${ROOT_PATH}/utils/log.sh"

if [ "${ACTION}" == "init" ]; then
  if [ "${MODE}" == "dev" ]; then
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml instant" "Failed to deploy hapi-proxy"
  else
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml -c ${COMPOSE_FILE_PATH}/docker-compose.prod.yml instant" "Failed to deploy hapi-proxy"
  fi
elif [ "${ACTION}" == "up" ]; then
  if [ "${MODE}" == "dev" ]; then
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml instant" "Failed to deploy hapi-proxy"
  else
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml -c ${COMPOSE_FILE_PATH}/docker-compose.prod.yml instant" "Failed to deploy hapi-proxy"
  fi
elif [ "${ACTION}" == "down" ]; then
  try "docker service scale instant_hapi-proxy=0" "Failed to scale down hapi-proxy"
elif [ "${ACTION}" == "destroy" ]; then
  try "docker service rm instant_hapi-proxy" "Failed to destroy hapi-proxy"
else
  log error "Valid options are: init, up, down, or destroy"
fi
