#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare UTILS_SERVICES=()
declare KAFKA_SERVICES=()
declare SERVICE_NAMES=()

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  UTILS_SERVICES=(
    "kafdrop"
    "kafka-minion"
  )
  KAFKA_SERVICES=(
    "kafka-01"
  )
  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    KAFKA_SERVICES=(
      "${KAFKA_SERVICES[@]}"
      "kafka-02"
      "kafka-03"
    )
  fi

  SERVICE_NAMES=(
    "${UTILS_SERVICES[@]}"
    "${KAFKA_SERVICES[@]}"
  )

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly UTILS_SERVICES
  readonly KAFKA_SERVICES
  readonly SERVICE_NAMES
}

# shellcheck disable=SC1091
function import_sources() {
  source "${UTILS_PATH}/docker-utils.sh"
  source "${UTILS_PATH}/config-utils.sh"
  source "${UTILS_PATH}/log.sh"
}

function initialize_package() {
  local kafka_cluster_compose_filename=""
  local kafka_utils_dev_compose_filename=""

  if [[ "${MODE}" == "dev" ]]; then
    log info "Running package in DEV mode"
    kafka_utils_dev_compose_filename="docker-compose.dev.kafka-utils.yml"
  else
    log info "Running package in PROD mode"
  fi

  if [[ $CLUSTERED_MODE == "true" ]]; then
    kafka_cluster_compose_filename="docker-compose.cluster.kafka.yml"
  fi

  (
    log info "Deploy Kafka"

    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.kafka.yml" "$kafka_cluster_compose_filename"
    docker::deploy_sanity "${KAFKA_SERVICES[@]}"

    for service_name in "${KAFKA_SERVICES[@]}"; do
      config::await_service_reachable "$service_name" "Kafka Server started"
    done

    log info "Deploy the other services dependent of Kafka"

    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.kafka-utils.yml" "$kafka_utils_dev_compose_filename"
    docker::deploy_sanity "${UTILS_SERVICES[@]}"
  ) || {
    log error "Failed to deploy package"
    exit 1
  }

  log info "Await Kafdrop to be running and responding"
  config::await_service_running "kafdrop" "${COMPOSE_FILE_PATH}"/docker-compose.await-helper.yml "${KAFDROP_INSTANCES}"

  docker::deploy_config_importer "$COMPOSE_FILE_PATH/importer/docker-compose.config.yml" "message-bus-kafka-config-importer" "kafka"
}

function destroy_package() {
  docker::service_destroy "${SERVICE_NAMES[@]}" "message-bus-kafka-config-importer"

  docker::try_remove_volume kafka-01-data

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
      log info "Running package in Cluster node mode"
    else
      log info "Running package in Single node mode"
    fi

    initialize_package
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down package"

    docker::scale_services_down "${SERVICE_NAMES[@]}"
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying package"
    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
