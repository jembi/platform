#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare kafka_services=()
declare dgraph_services=()
declare combined_services=()
declare service_names=()
declare volume_names=()

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils/"

  dgraph_services=("jempi-ratel")
  volume_names=("jempi-zero-01-data")

  for i in {1..3}; do
    kafka_services=(
      "${kafka_services[@]}"
      "jempi-kafka-0$i"
    )
    dgraph_services=(
      "${dgraph_services[@]}"
      "jempi-alpha-0$i"
    )
    volume_names=(
      "${volume_names[@]}"
      "jempi-kafka-0$i-data"
      "jempi-alpha-0$i-data"
    )
  done

  combined_services=(
    "jempi-async-receiver"
    "jempi-sync-receiver"
    "jempi-pre-processor"
    "jempi-controller"
    "jempi-em-calculator"
    "jempi-linker"
  )

  service_names=(
    "${kafka_services[@]}"
    "${dgraph_services[@]}"
    "${combined_services[@]}"
    "jempi-kafdrop"
    "jempi-zero-01"
    "jempi-api"
  )

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly kafka_services
  readonly dgraph_services
  readonly combined_services
  readonly service_names
  readonly volume_names
}

# shellcheck disable=SC1091
function import_sources() {
  source "${UTILS_PATH}/docker-utils.sh"
  source "${UTILS_PATH}/config-utils.sh"
  source "${UTILS_PATH}/log.sh"
}

function initialize_package() {
  local kafdrop_dev_compose_param=""
  local dgraph_dev_compose_param=""
  local dgraph_zero_dev_compose_param=""
  local combined_dev_compose_param=""
  local api_dev_compose_param=""
  local dgraph_cluster_compose_param=""
  local dgraph_zero_cluster_compose_param=""

  if [[ "$MODE" == "dev" ]]; then
    log info "Running Client Registry JeMPI package in DEV mode"
    kafdrop_dev_compose_param="docker-compose.kafdrop-dev.yml"
    dgraph_dev_compose_param="docker-compose.dgraph-dev.yml"
    dgraph_zero_dev_compose_param="docker-compose.dgraph-zero-dev.yml"
    combined_dev_compose_param="docker-compose.combined-dev.yml"
    api_dev_compose_param="docker-compose.api-dev.yml"
  else
    log info "Running Client Registry JeMPI package in PROD mode"
  fi

  if [[ "$NODE_MODE" == "cluster" ]]; then
    dgraph_cluster_compose_param="docker-compose.dgraph-cluster.yml"
    dgraph_zero_cluster_compose_param="docker-compose.dgraph-zero-cluster.yml"
  fi

  (
    log info "Deploy Kafka"
    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.kafka.yml"
    docker::deploy_sanity "${kafka_services[@]}"

    log info "Deploy Kafdrop"
    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.kafdrop.yml" "$kafdrop_dev_compose_param"
    docker::deploy_sanity "jempi-kafdrop"

    docker::deploy_config_importer "$COMPOSE_FILE_PATH/importer/docker-compose.config.yml" "jempi-kafka-config-importer" "jempi-kafka"

    log info "Deploy Dgraph"
    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.dgraph-zero.yml" "$dgraph_zero_dev_compose_param" "$dgraph_zero_cluster_compose_param"
    docker::deploy_sanity "jempi-zero-01"

    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.dgraph.yml" "$dgraph_dev_compose_param" "$dgraph_cluster_compose_param"
    docker::deploy_sanity "${dgraph_services[@]}"

    log info "Deploy other combined services"
    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.combined.yml" "$combined_dev_compose_param"
    docker::deploy_sanity "${combined_services[@]}"

    log info "Deploy JeMPI API"
    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.api.yml" "$api_dev_compose_param"
    docker::deploy_sanity "jempi-api"

    log info "Register openHIM channels"
    if docker service ps -q instant_openhim-core &>/dev/null; then
      docker::deploy_config_importer "$COMPOSE_FILE_PATH/importer/openhim/docker-compose.config.yml" "jempi-openhim-config-importer" "openhim"
    else
      log warn "Service 'interoperability-layer-openhim' does not appear to be running... skipping configuring of async/sync JeMPI channels"
    fi

  ) ||
    {
      log error "Failed to deploy Client Registry JeMPI package"
      exit 1
    }
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
  docker::service_destroy jempi-kafka-config-importer
  docker::service_destroy jempi-openhim-config-importer

  for service_name in "${service_names[@]}"; do
    docker::service_destroy "$service_name"
  done

  for volume__name in "${volume_names[@]}"; do
    docker::try_remove_volume "$volume__name"
  done

  if [[ "${NODE_MODE}" == "cluster" ]]; then
    log warn "Volumes are only deleted on the host on which the command is run. Postgres volumes on other nodes are not deleted"
  fi

  docker::prune_configs "jempi-kafka"
}

main() {
  init_vars "$@"
  import_sources

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    log info "Running Client Registry JeMPI package in ${NODE_MODE} node mode"

    initialize_package
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down Client Registry JeMPI"

    scale_services_down
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying Client Registry JeMPI"

    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
