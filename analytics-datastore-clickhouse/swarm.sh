#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare ROOT_PATH=""
declare nodes_mode=""
declare service_names=()

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  ROOT_PATH="${COMPOSE_FILE_PATH}/.."

  if [[ "${NODE_MODE}" == "cluster" ]]; then
    nodes_mode=".${NODE_MODE}"
    service_names=(
      "analytics-datastore-clickhouse-01"
      "analytics-datastore-clickhouse-02"
      "analytics-datastore-clickhouse-03"
      "analytics-datastore-clickhouse-04"
    )
  else
    service_names=(
      "analytics-datastore-clickhouse"
    )
  fi

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly ROOT_PATH
  readonly nodes_mode
  readonly service_names
}

# shellcheck disable=SC1091
function import_sources() {
  source "${ROOT_PATH}/utils/docker-utils.sh"
  source "${ROOT_PATH}/utils/log.sh"
}

function initialize_package() {
  local clickhouse_dev_compose_param=""
  if [[ "${MODE}" == "dev" ]]; then
    log info "Running Analytics Datastore Clickhouse package in DEV mode"
    clickhouse_dev_compose_param="docker-compose$nodes_mode.dev.yml"
  else
    log info "Running Analytics Datastore Clickhouse package in PROD mode"
  fi

  (
    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose$nodes_mode.yml" "$clickhouse_dev_compose_param"
    docker::deploy_sanity "${service_names[@]}"
  ) || {
    log error "Failed to deploy Analytics Datastore Clickhouse package"
    exit 1
  }

  docker::deploy_config_importer "$COMPOSE_FILE_PATH/importer/docker-compose.config.yml" "clickhouse-config-importer" "clickhouse"
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
  docker::service_destroy clickhouse-config-importer

  for service_name in "${service_names[@]}"; do
    docker::service_destroy "$service_name"
  done

  if [[ "$NODE_MODE" == "cluster" ]]; then
    docker::try_remove_volume clickhouse-data-01 clickhouse-data-04
    log warn "Volumes are only deleted on the host on which the command is run. Cluster volumes on other nodes are not deleted"
  else
    docker::try_remove_volume clickhouse-data
  fi

  docker::prune_configs "clickhouse"
}

main() {
  init_vars "$@"
  import_sources

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    log info "Running Analytics Datastore Clickhouse package in ${NODE_MODE} node mode"

    initialize_package
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down Analytics Datastore Clickhouse"

    scale_services_down
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying Analytics Datastore Clickhouse"

    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
