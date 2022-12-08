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

nodes_mode=""
service_names=()
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
readonly nodes_mode
readonly service_names

main() {
  ################################ INIT / UP ################################
  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    log info "Running Analytics Datastore Clickhouse package in ${NODE_MODE} node mode"

    local clickhouse_dev_compose_param=""
    if [[ "${MODE}" == "dev" ]]; then
      log info "Running Analytics Datastore Clickhouse package in DEV mode"
      clickhouse_dev_compose_param="docker-compose$nodes_mode.dev.yml"
    fi

    (
      docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose$nodes_mode.yml" "$clickhouse_dev_compose_param" "${service_names}"
    ) || {
      log error "Failed to deploy Analytics Datastore Clickhouse package"
      exit 1
    }

    docker::deploy_config_importer "$COMPOSE_FILE_PATH/importer" "clickhouse-config-importer" "clickhouse"

  ################################ DOWN ################################
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down Analytics Datastore Clickhouse"

    for service_name in "${service_names[@]}"; do
      try "docker service scale instant_$service_name=0" "Failed to scale down $service_name"
    done

  ################################ DESTROY ################################
  elif [[ "${ACTION}" == "destroy" ]]; then
    docker::service_destroy clickhouse-config-importer

    for service_name in "${service_names[@]}"; do
      docker::service_destroy "$service_name"
    done

    if [[ "$NODE_MODE" == "cluster" ]]; then
      docker::volume_destroy clickhouse-data-01 clickhouse-data-04
      log warn "Volumes are only deleted on the host on which the command is run. Cluster volumes on other nodes are not deleted"
    else
      docker::volume_destroy clickhouse-data
    fi

    docker::prune_configs "clickhouse"
  ################################ - ################################
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
