#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare service_names=()
declare scaled_services=()

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  scaled_services=(
    "grafana"
    "prometheus"
    "prometheus-kafka-adapter"
  )
  if [[ "${NODE_MODE}" == "cluster" ]]; then
    scaled_services=(
      "${scaled_services[@]}"
      "prometheus_backup"
    )
  fi
  service_names=(
    "${scaled_services[@]}"
    "cadvisor"
    "node-exporter"
  )

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly service_names
  readonly scaled_services
}

# shellcheck disable=SC1091
function import_sources() {
  source "${UTILS_PATH}/docker-utils.sh"
  source "${UTILS_PATH}/config-utils.sh"
  source "${UTILS_PATH}/log.sh"
}

function remove_service() {
  local -r SERVICE_NAME=${1:?"FATAL: await_container_startup parameter not provided"}

  try "docker service rm instant_$SERVICE_NAME" catch "Failed to remove service $SERVICE_NAME"
  docker::await_service_destroy "$SERVICE_NAME"
}

function initialize_package() {
  local monitoring_dev_compose_filename=""
  local monitoring_cluster_compose_filename=""

  if [[ "${NODE_MODE}" == "cluster" ]]; then
    monitoring_cluster_compose_filename="docker-compose.cluster.yml"
  fi

  if [[ "${MODE}" == "dev" ]]; then
    log info "Running Monitoring package in DEV mode"
    monitoring_dev_compose_filename="docker-compose.dev.yml"
  else
    log info "Running Monitoring package in PROD mode"
  fi

  (
    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.yml" "$monitoring_dev_compose_filename" "$monitoring_cluster_compose_filename"
    docker::deploy_sanity "${service_names[@]}"
  ) || {
    log error "Failed to deploy Monitoring package"
    exit 1
  }
}

function scale_services_down() {
  for service_name in "${scaled_services[@]}"; do
    try \
      "docker service scale instant_$service_name=0" \
      catch \
      "Failed to scale down $service_name"
  done

  remove_service cadvisor
  remove_service node-exporter
}

function destroy_package() {
  for service_name in "${scaled_services[@]}"; do
    docker::service_destroy "$service_name"
  done

  remove_service cadvisor
  remove_service node-exporter

  docker::try_remove_volume prometheus_data grafana_data

  if [[ $NODE_MODE == "cluster" ]]; then
    log warn "Volumes are only deleted on the host on which the command is run. Monitoring volumes on other nodes are not deleted"
  fi

  docker::prune_configs "grafana"
  docker::prune_configs "prometheus"
}

main() {
  init_vars "$@"
  import_sources

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    log info "Running Monitoring package in ${NODE_MODE} node mode"

    initialize_package
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down Monitoring"

    scale_services_down
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying Monitoring"

    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
