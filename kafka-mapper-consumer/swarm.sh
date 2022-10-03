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
. "${ROOT_PATH}/utils/config-utils.sh"
. "${ROOT_PATH}/utils/log.sh"

main() {
  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    config::set_config_digests "${COMPOSE_FILE_PATH}"/docker-compose.yml
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml instant" "Failed to deploy Kafka Mapper Consumer"

    config::remove_stale_service_configs "${COMPOSE_FILE_PATH}"/docker-compose.yml "kafka-mapper-consumer"
  elif [[ "${ACTION}" == "down" ]]; then
    try "docker service scale instant_kafka-mapper-consumer=0" "Failed to scale down kafka-mapper-consumer"
  elif [[ "${ACTION}" == "destroy" ]]; then
    docker::service_destroy kafka-mapper-consumer

    docker::prune_configs "kafka-mapper-consumer"
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
