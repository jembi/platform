#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare SERVICE_NAMES=()
declare SCALED_SERVICES=()

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  SCALED_SERVICES=(
    "grafana"
    "prometheus"
    "loki"
    "minio-01"
  )
  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    SCALED_SERVICES=(
      "${SCALED_SERVICES[@]}"
      "prometheus_backup"
      "minio-02"
      "minio-03"
      "minio-04"
    )
  fi
  SERVICE_NAMES=(
    "${SCALED_SERVICES[@]}"
    "cadvisor"
    "node-exporter"
    "promtail"
  )

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly SERVICE_NAMES
  readonly SCALED_SERVICES
}

# shellcheck disable=SC1091
function import_sources() {
  source "${UTILS_PATH}/docker-utils.sh"
  source "${UTILS_PATH}/config-utils.sh"
  source "${UTILS_PATH}/log.sh"
}

function initialize_package() {
  local monitoring_dev_compose_filename=""
  local monitoring_cluster_compose_filename=""

  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    monitoring_cluster_compose_filename="docker-compose.cluster.yml"
    export NUM_MINIO_SERVERS=4
  else
    export NUM_MINIO_SERVERS=1
  fi

  if [[ "${MODE}" == "dev" ]]; then
    log info "Running package in DEV mode"
    monitoring_dev_compose_filename="docker-compose.dev.yml"
  else
    log info "Running package in PROD mode"
  fi

  (
    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.yml" "$monitoring_dev_compose_filename" "$monitoring_cluster_compose_filename"
    docker::deploy_sanity "${SERVICE_NAMES[@]}"
  ) || {
    log error "Failed to deploy package"
    exit 1
  }
}

function scale_services_down() {
  docker::scale_services_down "${SCALED_SERVICES[@]}"

  docker::service_destroy "cadvisor" "node-exporter" "promtail"
}

function destroy_package() {
  docker::service_destroy "${SERVICE_NAMES[@]}"

  docker::try_remove_volume prometheus-data grafana-data minio-01-data1 minio-01-data2 prometheus_data_backup loki-data

  if [[ $CLUSTERED_MODE == "true" ]]; then
    sleep 5
    docker::try_remove_volume minio-02-data1 minio-02-data2
    log warn "Volumes are only deleted on the host on which the command is run. Monitoring volumes on other nodes are not deleted"
  fi

  docker::prune_configs "grafana" "prometheus" "promtail" "loki"
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

    scale_services_down
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying package"
    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
