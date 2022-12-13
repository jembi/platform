#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare ROOT_PATH=""
declare service_names=()

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  ROOT_PATH="${COMPOSE_FILE_PATH}/.."

  service_names=(
    "grafana"
    "prometheus"
    "prometheus-kafka-adapter"
    "cadvisor"
    "node-exporter"
  )

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly ROOT_PATH
  readonly service_names
}

# shellcheck disable=SC1091
function import_sources() {
  source "${ROOT_PATH}/utils/docker-utils.sh"
  source "${ROOT_PATH}/utils/config-utils.sh"
  source "${ROOT_PATH}/utils/log.sh"
}

function initialize_package() {
  local monitoring_dev_compose_param=""

  if [[ "${MODE}" == "dev" ]]; then
    log info "Running Monitoring package in DEV mode"
    monitoring_dev_compose_param="docker-compose.dev.yml"
  else
    log info "Running Monitoring package in PROD mode"
  fi

  (
    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.yml" "$monitoring_dev_compose_param"
    docker::deploy_sanity "${service_names[@]}"
  ) || {
    log error "Failed to deploy Monitoring package"
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

  docker::await_service_destroy cadvisor
  docker::await_service_destroy node-exporter
}

function destroy_package() {
  for service_name in "${service_names[@]}"; do
    docker::service_destroy "$service_name"
  done

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
