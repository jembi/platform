#!/bin/bash
readonly ACTION=$1
readonly MODE=$2

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
  kafka_0_cluster_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.cluster.kafka-0.yml"
  kafka_1_cluster_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.cluster.kafka-1.yml"
else
  log info "Running Message Bus Kafka package in Single node mode"
  kafka_0_cluster_compose_param=""
  kafka_1_cluster_compose_param=""
fi

if [[ "${MODE}" == "dev" ]]; then
  log info "Running Message Bus Kafka package in DEV mode"
  kafka_1_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.kafka-1.yml"
  kafka_2_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.kafka-2.yml"
else
  log info "Running Message Bus Kafka package in PROD mode"
  kafka_1_dev_compose_param=""
  kafka_2_dev_compose_param=""
fi

if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
  config::set_config_digests "${COMPOSE_FILE_PATH}"/importer/docker-compose.config.yml

  log info "Deploy Zookeeper"
  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.kafka-0.yml $kafka_0_cluster_compose_param instant" "Failed to deploy Message Bus Kafka"

  docker::await_container_startup zookeeper-1
  docker::await_container_status zookeeper-1 Running

  if [[ $STATEFUL_NODES == "cluster" ]]; then
    docker::await_container_startup zookeeper-2
    docker::await_container_status zookeeper-2 Running

    docker::await_container_startup zookeeper-3
    docker::await_container_status zookeeper-3 Running
  fi

  log info "Deploy Kafka"
  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.kafka-1.yml $kafka_1_cluster_compose_param $kafka_1_dev_compose_param instant" "Failed to deploy Message Bus Kafka"

  docker::await_container_startup kafka
  docker::await_container_status kafka Running

  config::await_service_reachable "kafka" "Connected"

  log info "Deploy the other services dependent of Kafka"
  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.kafka-2.yml $kafka_2_dev_compose_param instant" "Failed to deploy Message Bus Kafka"

  config::await_service_running "kafka" "${COMPOSE_FILE_PATH}"/docker-compose.await-helper.yml "${KAFKA_INSTANCES}"

  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/importer/docker-compose.config.yml instant" "Failed to deploy Message Bus Kafka"

  config::remove_stale_service_configs "${COMPOSE_FILE_PATH}"/importer/docker-compose.config.yml "ethiopia"
  config::remove_config_importer message-bus-kafka-config-importer

  if [ "$STATEFUL_NODES" == "cluster" ]; then
    docker::deploy_sanity kafka kafdrop kafka-minion zookeeper-1 zookeeper-2 zookeeper-3
  else
    docker::deploy_sanity kafka kafdrop kafka-minion zookeeper-1
  fi
elif [[ "${ACTION}" == "down" ]]; then
  try "docker service scale instant_zookeeper-1=0 instant_kafdrop=0 instant_kafka-minion=0" "Failed to scale down zookeeper, kafdrop and kafka-minion"

  try "docker service scale instant_kafka=0" "Failed to scale kafka down"
  if [[ $STATEFUL_NODES == "cluster" ]]; then
    try "docker service scale instant_zookeeper-2=0" "Failed to scale down zookeeper cluster"
    try "docker service scale instant_zookeeper-3=0" "Failed to scale down zookeeper cluster"
  fi
elif [[ "${ACTION}" == "destroy" ]]; then
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
