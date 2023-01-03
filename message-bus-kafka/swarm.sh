#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare ZOOKEEPER_SERVICES=()
declare UTILS_SERVICES=()
declare SERVICE_NAMES=()

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  ZOOKEEPER_SERVICES=(
    "zookeeper-1"
  )

  UTILS_SERVICES=(
    "kafdrop"
    "kafka-minion"
  )

  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    ZOOKEEPER_SERVICES=(
      "${ZOOKEEPER_SERVICES[@]}"
      "zookeeper-2"
      "zookeeper-3"
    )
  fi

  SERVICE_NAMES=(
    "${ZOOKEEPER_SERVICES[@]}"
    "${UTILS_SERVICES[@]}"
    "kafka"
  )

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly ZOOKEEPER_SERVICES
  readonly SERVICE_NAMES
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
    package::log info "Running package in DEV mode"
    kafka_dev_compose_filename="docker-compose.dev.kafka.yml"
    kafka_utils_dev_compose_filename="docker-compose.dev.kafka-utils.yml"
  else
    package::log info "Running package in PROD mode"
  fi

  if [[ $CLUSTERED_MODE == "cluster" ]]; then
    kafka_zoo_cluster_compose_filename="docker-compose.cluster.kafka-zoo.yml"
    kafka_cluster_compose_filename="docker-compose.cluster.kafka.yml"
  fi

  (
    log info "Deploy Zookeeper"

    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.kafka-zoo.yml" "$kafka_zoo_cluster_compose_filename"
    docker::deploy_sanity "${ZOOKEEPER_SERVICES[@]}"

    log info "Deploy Kafka"

    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.kafka.yml" "$kafka_cluster_compose_filename" "$kafka_dev_compose_filename"
    docker::deploy_sanity "kafka"
    config::await_service_reachable "kafka" "Connected"

    log info "Deploy the other services dependent of Kafka"

    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.kafka-utils.yml" "$kafka_utils_dev_compose_filename"
    docker::deploy_sanity "${UTILS_SERVICES[@]}"
  ) || {
    package::log error "Failed to deploy package"
    exit 1
  }

  config::await_service_running "kafka" "${COMPOSE_FILE_PATH}"/docker-compose.await-helper.yml "${KAFKA_INSTANCES}"

  docker::deploy_config_importer "$COMPOSE_FILE_PATH/importer/docker-compose.config.yml" "message-bus-kafka-config-importer" "kafka"
}

function destroy_package() {
  docker::service_destroy "${SERVICE_NAMES[@]}" "message-bus-kafka-config-importer"

  docker::try_remove_volume zookeeper-1-volume kafka-volume

  if [[ "$CLUSTERED_MODE" == "true" ]]; then
    log warn "Volumes are only deleted on the host on which the command is run. Cluster volumes on other nodes are not deleted"
  fi

  docker::prune_configs "kafka"
}

main() {
  init_vars "$@"
  import_sources

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    if [[ "${CLUSTERED_MODE}" == "true" ]]; then
      package::log info "Running package in Cluster node mode"
    else
      package::log info "Running package in Single node mode"
    fi

    initialize_package
  elif [[ "${ACTION}" == "down" ]]; then
    package::log info "Scaling down package"

    docker::scale_services_down "${SERVICE_NAMES[@]}"
  elif [[ "${ACTION}" == "destroy" ]]; then
    package::log info "Destroying package"
    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
