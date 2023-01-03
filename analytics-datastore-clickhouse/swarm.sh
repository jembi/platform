#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare PACKAGE_NAME=""
declare NODE_MODE_PREFIX=""
declare SERVICE_NAMES=()

function init_vars() {
  ACTION=$1
  MODE=$2

  PACKAGE_NAME=$(basename "$PWD" | sed -e 's/-/ /g' -e 's/\b\(.\)/\u\1/g')

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    NODE_MODE_PREFIX=".cluster"
    for i in {1..4}; do
      SERVICE_NAMES=(
        "${SERVICE_NAMES[@]}"
        "analytics-datastore-clickhouse-0$i"
      )
    done
  else
    SERVICE_NAMES=(
      "analytics-datastore-clickhouse"
    )
  fi

  readonly ACTION
  readonly MODE
  readonly PACKAGE_NAME
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly NODE_MODE_PREFIX
  readonly SERVICE_NAMES
}

# shellcheck disable=SC1091
function import_sources() {
  source "${UTILS_PATH}/docker-utils.sh"
  source "${UTILS_PATH}/log.sh"
}

function initialize_package() {
  local clickhouse_dev_compose_filename=""
  if [[ "${MODE}" == "dev" ]]; then
    log info "Running $PACKAGE_NAME package in DEV mode"
    clickhouse_dev_compose_filename="docker-compose$NODE_MODE_PREFIX.dev.yml"
  else
    log info "Running $PACKAGE_NAME package in PROD mode"
  fi

  (
    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose$NODE_MODE_PREFIX.yml" "$clickhouse_dev_compose_filename"
    docker::deploy_sanity "${SERVICE_NAMES[@]}"
  ) || {
    log error "Failed to deploy $PACKAGE_NAME package"
    exit 1
  }

  docker::deploy_config_importer "$COMPOSE_FILE_PATH/importer/docker-compose.config.yml" "clickhouse-config-importer" "clickhouse"
}

function destroy_package() {
  docker::service_destroy "${SERVICE_NAMES[@]}" "clickhouse-config-importer"

  if [[ "$CLUSTERED_MODE" == "true" ]]; then
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
    if [[ "${CLUSTERED_MODE}" == "true" ]]; then
      log info "Running $PACKAGE_NAME package in Cluster node mode"
    else
      log info "Running $PACKAGE_NAME package in Single node mode"
    fi

    initialize_package
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down $PACKAGE_NAME"

    docker::scale_services_down "${SERVICE_NAMES[@]}"
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying $PACKAGE_NAME"

    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
