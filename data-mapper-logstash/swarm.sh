#!/bin/bash

# Arguments
readonly ACTION=$1
readonly MODE=$2

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

inject_pipeline_elastic_hosts() {
  ES_HOSTS=${ES_HOSTS:-"\"analytics-datastore-elastic-search:9200\""}
  for file in "${COMPOSE_FILE_PATH}"/pipeline/*.conf; do
    sed -i "s/\$ES_HOSTS/${ES_HOSTS}/g" "${file}"
  done
}

if [[ "$MODE" == "dev" ]]; then
  log info "Running Data Mapper Logstash package in DEV mode"
  logstash_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  log info "Running Data Mapper Logstash package in PROD mode"
  logstash_dev_compose_param=""
fi

if [[ "$LOGSTASH_DEV_MOUNT" == "true" ]]; then
  if [[ -z $LOGSTASH_PACKAGE_PATH ]]; then
    log error "LOGSTASH_PACKAGE_PATH environment variable not specified. Please specify LOGSTASH_PACKAGE_PATH as stated in the README."
    exit 1
  fi

  log info "Running Data Mapper Logstash package with dev mount"
  logstash_dev_mount_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev-mnt.yml"
else
  logstash_dev_mount_compose_param=""
fi

if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then

  if [[ "${STATEFUL_NODES}" == "cluster" ]]; then
    export LOGSTASH_YML_CONFIG="logstash-logstash.cluster.yml"
  else
    export LOGSTASH_YML_CONFIG="logstash-logstash.yml"
  fi

  inject_pipeline_elastic_hosts

  config::set_config_digests "${COMPOSE_FILE_PATH}"/docker-compose.yml

  config::generate_service_configs data-mapper-logstash /usr/share/logstash "${COMPOSE_FILE_PATH}/pipeline" "${COMPOSE_FILE_PATH}" logstash
  logstash_temp_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.tmp.yml"

  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml $logstash_dev_compose_param $logstash_dev_mount_compose_param $logstash_temp_compose_param instant" "Failed to deploy Data Mapper Logstash"

  docker::await_container_startup data-mapper-logstash
  docker::await_container_status data-mapper-logstash Running

  config::remove_stale_service_configs "${COMPOSE_FILE_PATH}/docker-compose.yml" "logstash"

  docker::prune_configs logstash

  log info "Done"
elif [[ "${ACTION}" == "down" ]]; then
  try "docker service scale instant_data-mapper-logstash=0" "Failed to scale down data-mapper-logstash"
elif [[ "${ACTION}" == "destroy" ]]; then
  docker::service_destroy data-mapper-logstash
  docker::try_remove_volume logstash-data

  docker::prune_configs logstash
else
  log error "Valid options are: init, up, down, or destroy"
fi
