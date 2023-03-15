#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare NODE_MODE_PREFIX=""
declare STACK="clickhouse"

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    NODE_MODE_PREFIX=".cluster"
  fi

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly NODE_MODE_PREFIX
  readonly STACK
}

# shellcheck disable=SC1091
function import_sources() {
  source "${UTILS_PATH}/docker-utils.sh"
  source "${UTILS_PATH}/log.sh"
}

function initialize_package() {
  local clickhouse_dev_compose_filename=""
  if [[ "${MODE}" == "dev" ]]; then
    log info "Running package in DEV mode"
    clickhouse_dev_compose_filename="docker-compose$NODE_MODE_PREFIX.dev.yml"
  else
    log info "Running package in PROD mode"
  fi

  (
    docker::deploy_service $STACK "${COMPOSE_FILE_PATH}" "docker-compose$NODE_MODE_PREFIX.yml" "$clickhouse_dev_compose_filename"
  ) || {
    log error "Failed to deploy package"
    exit 1
  }

  docker::deploy_config_importer $STACK "$COMPOSE_FILE_PATH/importer/docker-compose.config.yml" "clickhouse-config-importer" "clickhouse"
}

function destroy_package() {
  docker::stack_destroy $STACK

  if [[ "$CLUSTERED_MODE" == "true" ]]; then
    docker::try_remove_volume $STACK clickhouse-data-01 clickhouse-data-04
    log warn "Volumes are only deleted on the host on which the command is run. Cluster volumes on other nodes are not deleted"
  else
    docker::try_remove_volume $STACK clickhouse-data
  fi

  docker::prune_configs "clickhouse"
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

    docker::scale_services $STACK 0
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying package"

    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
