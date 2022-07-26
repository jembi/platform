#!/bin/bash

STATEFUL_NODES=${STATEFUL_NODES:-"cluster"}

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)

# Import libraries
ROOT_PATH="${COMPOSE_FILE_PATH}/.."
. "${ROOT_PATH}/utils/config-utils.sh"
. "${ROOT_PATH}/utils/docker-utils.sh"
. "${ROOT_PATH}/utils/log.sh"

readonly KAFKA_INSTANCES=${KAFKA_INSTANCES:-1}
export KAFKA_INSTANCES

if [[ $STATEFUL_NODES == "cluster" ]]; then
  log info "Running Message Bus Kafka package in Cluster node mode"
  kafkaClusterComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.cluster.yml"
else
  log info "Running Message Bus Kafka package in Single node mode"
  kafkaClusterComposeParam=""
fi

if [[ $2 == "dev" ]]; then
  log info "Running Message Bus Kafka package in DEV mode"
  kafkaDevComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  log info "Running Message Bus Kafka package in PROD mode"
  kafkaDevComposeParam=""
fi

if [[ $1 == "init" ]] || [[ $1 == "up" ]]; then
  config::set_config_digests "${COMPOSE_FILE_PATH}"/importer/docker-compose.config.yml

  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml $kafkaClusterComposeParam $kafkaDevComposeParam instant" "Failed to deploy Message Bus Kafka"

  config::await_service_running "kafka" "${COMPOSE_FILE_PATH}"/docker-compose.await-helper.yml "${KAFKA_INSTANCES}"

  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/importer/docker-compose.config.yml instant" "Failed to deploy Message Bus Kafka"

  config::remove_stale_service_configs "${COMPOSE_FILE_PATH}"/importer/docker-compose.config.yml "ethiopia"
  config::remove_config_importer message-bus-kafka-config-importer
elif [[ $1 == "down" ]]; then
  try "docker service scale instant_zookeeper-1=0 instant_kafdrop=0" "Failed to scale down zookeeper and kafdrop"
  # You cannot scale a global service so we have to remove it
  try "docker service rm instant_kafka" "Failed to remove kafka"
  if [[ $STATEFUL_NODES == "cluster" ]]; then
    try "docker service scale instant_zookeeper-2=0" "Failed to scale down zookeeper cluster"
    try "docker service scale instant_zookeeper-3=0" "Failed to scale down zookeeper cluster"
  fi
elif [[ $1 == "destroy" ]]; then
  log info "Allow services to shut down before deleting volumes"

  docker::service_destroy zookeeper-1
  docker::service_destroy kafka
  docker::service_destroy kafdrop

  docker::try_remove_volume zookeeper-1-volume
  docker::try_remove_volume kafka-volume

  if [[ $STATEFUL_NODES == "cluster" ]]; then
    docker::service_destroy zookeeper-2
    docker::service_destroy zookeeper-3

    docker::try_remove_volume zookeeper-2-volume
    docker::try_remove_volume zookeeper-3-volume
    log notice "Volumes are only deleted on the host on which the command is run. Kafka volumes on other nodes are not deleted"
  fi

  log warn "docker service rm instant_message-bus-kafka-config-importer" ": message-bus-kafka-config-importer not removed... it's possible the service has already been removed"
else
  log error "Valid options are: init, up, down, or destroy"
fi
