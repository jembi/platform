#!/bin/bash

readonly STATEFUL_NODES=${STATEFUL_NODES:-"single"}
readonly KAFKA_INSTANCES=${KAFKA_INSTANCES:-1}
export KAFKA_INSTANCES

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)

# Import libraries
ROOT_PATH="${COMPOSE_FILE_PATH}/.."
. "${ROOT_PATH}/utils/config-utils.sh"
. "${ROOT_PATH}/utils/docker-utils.sh"
. "${ROOT_PATH}/utils/log.sh"


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
  try "docker service scale instant_zookeeper-1=0 instant_kafdrop=0 instant_kafka-minion=0" "Failed to scale down zookeeper, kafdrop and kafka-minion"

  try "docker service scale instant_kafka=0" "Failed to scale kafka down"
  if [[ $STATEFUL_NODES == "cluster" ]]; then
    try "docker service scale instant_zookeeper-2=0" "Failed to scale down zookeeper cluster"
    try "docker service scale instant_zookeeper-3=0" "Failed to scale down zookeeper cluster"
  fi
elif [[ $1 == "destroy" ]]; then
  log info "Allow services to shut down before deleting volumes"

  docker::service_destroy zookeeper-1
  docker::service_destroy kafka
  docker::service_destroy kafdrop
  docker::service_destroy message-bus-kafka-config-importer
  docker::service_destroy kafka-minion

  docker::try_remove_volume zookeeper-1-volume
  docker::try_remove_volume kafka-volume

  if [[ $STATEFUL_NODES == "cluster" ]]; then
    docker::service_destroy zookeeper-2
    docker::service_destroy zookeeper-3

    docker::try_remove_volume zookeeper-2-volume
    docker::try_remove_volume zookeeper-3-volume
    log warn "Volumes are only deleted on the host on which the command is run. Kafka volumes on other nodes are not deleted"
  fi

  docker::prune_configs "kafka"
else
  log error "Valid options are: init, up, down, or destroy"
fi
