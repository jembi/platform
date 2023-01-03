#!/bin/bash

declare ACTION=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare SERVICE_NAMES=""

function init_vars() {
  ACTION=$1

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  SERVICE_NAMES="kafka-mapper-consumer"

  readonly ACTION
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly SERVICE_NAMES
}

# shellcheck disable=SC1091
function import_sources() {
  source "${UTILS_PATH}/docker-utils.sh"
  source "${UTILS_PATH}/log.sh"
}

function initialize_package() {
  (
    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.yml"
    docker::deploy_sanity "${SERVICE_NAMES}"
  ) || {
    package::log error "Failed to deploy package"
    exit 1
  }
}

function destroy_package() {
  docker::service_destroy "${SERVICE_NAMES}"

  docker::prune_configs "kafka-mapper-consumer"
}

main() {
  init_vars "$@"
  import_sources

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    package::log info "Running package"

    initialize_package
  elif [[ "${ACTION}" == "down" ]]; then
    package::log info "Scaling down package"

    docker::scale_services_down "${SERVICE_NAMES}"
  elif [[ "${ACTION}" == "destroy" ]]; then
    package::log info "Destroying package"
    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
