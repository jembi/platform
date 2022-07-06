#!/bin/bash

# Arguments
ACTION=$1
MODE=$2

readonly LOGSTASH_DEV_MOUNT=$LOGSTASH_DEV_MOUNT

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)

# Import libraries
ROOT_PATH="${COMPOSE_FILE_PATH}/.."
. "${ROOT_PATH}/utils/config-utils.sh"
. "${ROOT_PATH}/utils/docker-utils.sh"
. "${ROOT_PATH}/utils/log.sh"

if [[ "$MODE" == "dev" ]]; then
  log info "Running Data Mapper Logstash package in DEV mode"
  LogstashDevComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  log info "Running Data Mapper Logstash package in PROD mode"
  LogstashDevComposeParam=""
fi

if [[ "$LOGSTASH_DEV_MOUNT" == "true" ]]; then
  if [[ -z $LOGSTASH_PACKAGE_PATH ]]; then
    log error "LOGSTASH_PACKAGE_PATH environment variable not specified. Please specify LOGSTASH_PACKAGE_PATH as stated in the README."
    exit 1
  fi

  log info "Running Data Mapper Logstash package with dev mount"
  LogstashDevMountComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.dev-mnt.yml"
else
  LogstashDevMountComposeParam=""
fi

if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then

  config::set_config_digests "${COMPOSE_FILE_PATH}"/docker-compose.yml

  config::generate_service_configs data-mapper-logstash /usr/share/logstash "${COMPOSE_FILE_PATH}/pipeline" "${COMPOSE_FILE_PATH}"
  LogstashTempComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.tmp.yml"

  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml $LogstashDevComposeParam $LogstashDevMountComposeParam $LogstashTempComposeParam instant" "Failed to deploy Data Mapper Logstash"

  docker::await_container_startup data-mapper-logstash
  docker::await_container_status data-mapper-logstash running

  config::remove_stale_service_configs "${COMPOSE_FILE_PATH}/docker-compose.yml" "logstash"

  log info "Done"
elif [[ "${ACTION}" == "down" ]]; then
  try "docker service scale instant_data-mapper-logstash=0" "Failed to scale down data-mapper-logstash"
elif [[ "${ACTION}" == "destroy" ]]; then
  try "docker service rm instant_data-mapper-logstash" "Failed to remove data-mapper-logstash"
else
  log error "Valid options are: init, up, down, or destroy"
fi
