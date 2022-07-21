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

verify_kafka() {
  local start_time
  start_time=$(date +%s)
  until [[ $(docker service ls -f name=instant_kafka --format "{{.Replicas}}") == *"${KAFKA_INSTANCES}/${KAFKA_INSTANCES}"* ]]; do
    config::timeout_check "${start_time}" "kafka to start"
    sleep 1
  done

  local await_helper_state
  await_helper_state=$(docker service ps instant_await-helper --format "{{.CurrentState}}")
  until [[ "${await_helper_state}" == *"Complete"* ]]; do
    config::timeout_check "${start_time}" "kafka heartbeat check"
    sleep 1

    await_helper_state=$(docker service ps instant_await-helper --format "{{.CurrentState}}")
    if [[ "${await_helper_state}" == *"Failed"* ]] || [[ "${await_helper_state}" == *"Rejected"* ]]; then
      log error "Fatal: Received error when trying to verify state of kafka. Error:
       $(docker service ps instant_await-helper --no-trunc --format '{{.Error}}')"
      exit 1
    fi
  done

  try "docker service rm instant_await-helper" "Failed to remove await helper"
}

if [[ $1 == "init" ]] || [[ $1 == "up" ]]; then
  config::set_config_digests "${COMPOSE_FILE_PATH}"/importer/docker-compose.config.yml

  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml $kafkaClusterComposeParam $kafkaDevComposeParam instant" "Failed to deploy Message Bus Kafka"
  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.await-helper.yml instant" "Failed to deploy await-helper"

  verify_kafka

  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/importer/docker-compose.config.yml instant" "Failed to deploy Message Bus Kafka"

  config::remove_stale_service_configs "${COMPOSE_FILE_PATH}"/importer/docker-compose.config.yml "ethiopia"
  config::remove_config_importer kafka-config-importer
elif [[ $1 == "down" ]]; then
  try "docker service scale instant_zookeeper-1=0 instant_kafdrop=0" "Failed to scale down zookeeper and kafdrop"
  # You cannot scale a global service so we have to remove it
  try "docker service rm instant_kafka" "Failed to remove kafka"
  if [[ $STATEFUL_NODES == "cluster" ]]; then
    try "docker service scale instant_zookeeper-2=0" "Failed to scale down zookeeper cluster"
    try "docker service scale instant_zookeeper-3=0" "Failed to scale down zookeeper cluster"
  fi
elif [[ $1 == "destroy" ]]; then
  try "docker service rm instant_zookeeper-1 instant_kafka instant_kafdrop" "Failed to destroy kafka"

  log info "Allow services to shut down before deleting volumes"

  config::await_service_removed instant_zookeeper-1
  config::await_service_removed instant_kafka
  config::await_service_removed instant_kafdrop

  try "docker volume rm instant_kafka-volume" "Failed to remove kafka volume"
  try "docker volume rm instant_zookeeper-1-volume" "Failed to remove zookeeper volume"

  if [[ $STATEFUL_NODES == "cluster" ]]; then
    try "docker service rm instant_zookeeper-2" "Failed to remove zookeeper cluster volumes"
    try "docker service rm instant_zookeeper-3" "Failed to remove zookeeper cluster volumes"
    log notice "Volumes are only deleted on the host on which the command is run. Kafka volumes on other nodes are not deleted"
  fi
else
  log error "Valid options are: init, up, down, or destroy"
fi
