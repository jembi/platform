#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare zookeeper_services=()
declare utils_services=()
declare service_names=()

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  zookeeper_services=(
    "zookeeper-1"
  )

  utils_services=(
    "kafdrop"
    "kafka-minion"
  )

  if [[ "${NODE_MODE}" == "cluster" ]]; then
    zookeeper_services=(
      "${zookeeper_services[@]}"
      "zookeeper-2"
      "zookeeper-3"
    )
  fi

  service_names=(
    "${zookeeper_services[@]}"
    "${utils_services[@]}"
    "kafka"
  )

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly zookeeper_services
  readonly service_names
}

# shellcheck disable=SC1091
function import_sources() {
  source "${UTILS_PATH}/docker-utils.sh"
  source "${UTILS_PATH}/config-utils.sh"
  source "${UTILS_PATH}/log.sh"
}

function initialize_package() {
  local kafka_dev_compose_filename=""
  local kafka_cluster_compose_filename=""
  local kafka_utils_dev_compose_filename=""
  local kafka_zoo_cluster_compose_filename=""

  if [[ "${MODE}" == "dev" ]]; then
    log info "Running Message Bus Kafka package in DEV mode"
    kafka_dev_compose_filename="docker-compose.dev.kafka.yml"
    kafka_utils_dev_compose_filename="docker-compose.dev.kafka-utils.yml"
  else
    log info "Running Message Bus Kafka package in PROD mode"
  fi

  if [[ $NODE_MODE == "cluster" ]]; then
    kafka_zoo_cluster_compose_filename="docker-compose.cluster.kafka-zoo.yml"
    kafka_cluster_compose_filename="docker-compose.cluster.kafka.yml"
  fi

  (
    log info "Deploy Zookeeper"

    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.kafka-zoo.yml" "$kafka_zoo_cluster_compose_filename"
    docker::deploy_sanity "${zookeeper_services[@]}"

    log info "Deploy Kafka"

    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.kafka.yml" "$kafka_cluster_compose_filename" "$kafka_dev_compose_filename"
    docker::deploy_sanity "kafka"
    config::await_service_reachable "kafka" "Connected"

    log info "Deploy the other services dependent of Kafka"

    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.kafka-utils.yml" "$kafka_utils_dev_compose_filename"
    docker::deploy_sanity "${utils_services[@]}"
  ) || {
    log error "Failed to deploy Message Bus Kafka package"
    exit 1
  }

  config::await_service_running "kafka" "${COMPOSE_FILE_PATH}"/docker-compose.await-helper.yml "${KAFKA_INSTANCES}"

  docker::deploy_config_importer "$COMPOSE_FILE_PATH/importer/docker-compose.config.yml" "message-bus-kafka-config-importer" "kafka"
}

function scale_services_down() {
  for service_name in "${service_names[@]}"; do
    try \
      "docker service scale instant_$service_name=0" \
      catch \
      "Failed to scale down $service_name"
  done
}

function destroy_package() {
  docker::service_destroy message-bus-kafka-config-importer

  for service_name in "${service_names[@]}"; do
    docker::service_destroy "$service_name"
  done

  docker::try_remove_volume zookeeper-1-volume kafka-volume

  if [[ "$NODE_MODE" == "cluster" ]]; then
    log warn "Volumes are only deleted on the host on which the command is run. Cluster volumes on other nodes are not deleted"
  fi

  docker::prune_configs "kafka"
}

main() {
  init_vars "$@"
  import_sources

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    log info "Running Message Bus Kafka package in ${NODE_MODE} node mode"

    initialize_package
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down Message Bus Kafka"

    scale_services_down
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying Message Bus Kafka"

    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
