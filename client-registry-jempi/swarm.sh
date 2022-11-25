#!/bin/bash

readonly ACTION=$1
readonly MODE=$2

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)
readonly COMPOSE_FILE_PATH

ROOT_PATH="${COMPOSE_FILE_PATH}/.."
readonly ROOT_PATH

. "${ROOT_PATH}/utils/config-utils.sh"
. "${ROOT_PATH}/utils/docker-utils.sh"
. "${ROOT_PATH}/utils/log.sh"

service_names=(
  "jempi-kafka-01"
  "jempi-kafka-02"
  "jempi-kafka-03"
  "jempi-kafdrop"
  "jempi-zero-01"
  "jempi-alpha-01"
  "jempi-alpha-02"
  "jempi-alpha-03"
  "jempi-ratel"
  "jempi-async-receiver"
  "jempi-sync-receiver"
  "jempi-pre-processor"
  "jempi-controller"
  "jempi-em-calculator"
  "jempi-linker"
  "jempi-api"
)
readonly service_names

main() {
  if [[ "$MODE" == "dev" ]]; then
    log info "Running Client Registry JeMPI package in DEV mode"
    kafdrop_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.kafdrop-dev.yml"
    dgraph_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dgraph-dev.yml"
    dgraph_zero_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dgraph-zero-dev.yml"
    combined_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.combined-dev.yml"
    api_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.api-dev.yml"
  else
    log info "Running Client Registry JeMPI package in PROD mode"
    kafdrop_dev_compose_param=""
    dgraph_dev_compose_param=""
    dgraph_zero_dev_compose_param=""
    combined_dev_compose_param=""
    api_dev_compose_param=""
  fi

  if [[ "$STATEFUL_NODES" == "cluster" ]]; then
    log info "Running in clustered mode"
    dgraph_cluster_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dgraph-cluster.yml"
    dgraph_zero_cluster_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dgraph-zero-cluster.yml"
  else
    log info "Running in single-node mode"
    dgraph_cluster_compose_param=""
    dgraph_zero_cluster_compose_param=""
  fi

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.kafka.yml instant" "Failed to deploy Client Registry - JeMPI (kafka.yml)"

    docker::await_service_ready jempi-kafka-01
    docker::await_service_ready jempi-kafka-02
    docker::await_service_ready jempi-kafka-03

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.kafdrop.yml $kafdrop_dev_compose_param instant" "Failed to deploy Client Registry - JeMPI (kafdrop.yml)"

    docker::await_service_ready jempi-kafdrop

    config::set_config_digests "${COMPOSE_FILE_PATH}"/importer/docker-compose.config.yml

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/importer/docker-compose.config.yml instant" "Failed to deploy jempi-kafka-config-importer"

    log info "Waiting to give JeMPI Kafka config importer time to run before cleaning up service"

    config::remove_config_importer jempi-kafka-config-importer
    config::await_service_removed instant_jempi-kafka-config-importer

    config::remove_stale_service_configs "${COMPOSE_FILE_PATH}"/importer/docker-compose.config.yml "jempi-kafka"

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.dgraph-zero.yml $dgraph_zero_dev_compose_param $dgraph_zero_cluster_compose_param instant" "Failed to deploy Client Registry - JeMPI (dgraph-zero.yml)"

    docker::await_service_ready jempi-zero-01

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.dgraph.yml $dgraph_dev_compose_param $dgraph_cluster_compose_param instant" "Failed to deploy Client Registry - JeMPI (dgraph.yml)"

    docker::await_service_ready jempi-alpha-01
    docker::await_service_ready jempi-alpha-02
    docker::await_service_ready jempi-alpha-03

    docker::await_service_ready jempi-ratel

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.combined.yml $combined_dev_compose_param instant" "Failed to deploy Client Registry - JeMPI (combined.yml)"

    docker::await_service_ready jempi-async-receiver
    docker::await_service_ready jempi-sync-receiver
    docker::await_service_ready jempi-pre-processor
    docker::await_service_ready jempi-controller
    docker::await_service_ready jempi-em-calculator
    docker::await_service_ready jempi-linker

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.api.yml $api_dev_compose_param instant" "Failed to deploy Client Registry - JeMPI (api.yml)"

    docker::await_service_ready jempi-api

    if docker service ps -q instant_openhim-core &>/dev/null; then
      config::set_config_digests "${COMPOSE_FILE_PATH}"/importer/openhim/docker-compose.config.yml

      try "docker stack deploy -c ${COMPOSE_FILE_PATH}/importer/openhim/docker-compose.config.yml instant" "Failed to deploy jempi-openhim-config-importer"

      log info "Waiting to give JeMPI Openhim config importer time to run before cleaning up service"

      config::remove_config_importer jempi-openhim-config-importer
      config::await_service_removed instant_jempi-openhim-config-importer
    else
      log warn "Service 'interoperability-layer-openhim' does not appear to running... skipping configuring of async/sync JeMPI channels"
    fi

    docker::deploy_sanity "${service_names[@]}"
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down client-registry-jempi"

    for service_name in "${service_names[@]}"; do
      try "docker service scale instant_$service_name=0" "Failed to scale down $service_name"
    done
  elif [[ "${ACTION}" == "destroy" ]]; then
    log warn "Volumes are only deleted on the host on which the command is run. Volumes on other nodes are not deleted"

    for service_name in "${service_names[@]}"; do
      docker::service_destroy "$service_name"
    done

    docker::service_destroy jempi-kafka-config-importer
    docker::service_destroy jempi-openhim-config-importer

    docker::try_remove_volume jempi-kafka-01-data
    docker::try_remove_volume jempi-kafka-02-data
    docker::try_remove_volume jempi-kafka-03-data

    docker::try_remove_volume jempi-zero-01-data

    docker::try_remove_volume jempi-alpha-01-data
    docker::try_remove_volume jempi-alpha-02-data
    docker::try_remove_volume jempi-alpha-03-data

    docker::prune_configs "jempi-kafka"
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
