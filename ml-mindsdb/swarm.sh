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
    "mindsdb"
  )
  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    SCALED_SERVICES=(
      "${SCALED_SERVICES[@]}"
    )
  fi
  SERVICE_NAMES=(
    "${SCALED_SERVICES[@]}"
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
  local mindsdb_dev_compose_filename=""
  local mindsdb_cluster_compose_filename=""

  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    mindsdb_cluster_compose_filename="docker-compose.cluster.yml"
  fi

  if [[ "${MODE}" == "dev" ]]; then
    log info "Running package in DEV mode"
    mindsdb_dev_compose_filename="docker-compose.dev.yml"
  else
    log info "Running package in PROD mode"
  fi

  (
    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.yml" "$mindsdb_dev_compose_filename" "$mindsdb_cluster_compose_filename"
    docker::deploy_sanity "${SERVICE_NAMES[@]}"
  ) || {
    log error "Failed to deploy package"
    exit 1
  }
}

function scale_services_down() {
  docker::scale_services_down "${SCALED_SERVICES[@]}"

  # docker::service_destroy
}

function destroy_package() {
  docker::service_destroy "${SERVICE_NAMES[@]}"

  # docker::try_remove_volume

  if [[ $CLUSTERED_MODE == "true" ]]; then
    log warn "Volumes are only deleted on the host on which the command is run. Monitoring volumes on other nodes are not deleted"
  fi

  # docker::prune_configs
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
