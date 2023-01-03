#!/bin/bash

declare ACTION=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare PACKAGE_NAME=""
declare SERVICE_NAMES=""

function init_vars() {
  ACTION=$1

  PACKAGE_NAME=$(basename "$PWD" | sed -e 's/-/ /g' -e 's/\b\(.\)/\u\1/g')

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  SERVICE_NAMES="job-scheduler-ofelia"

  readonly ACTION
  readonly PACKAGE_NAME
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly SERVICE_NAMES
}

# shellcheck disable=SC1091
function import_sources() {
  source "${UTILS_PATH}/docker-utils.sh"
  source "${UTILS_PATH}/config-utils.sh"
  source "${UTILS_PATH}/log.sh"
}

function initialize_package() {
  if [[ ! -f "${COMPOSE_FILE_PATH}/config.ini" ]]; then
    log error "FATAL: config.ini file does not exist, Aborting..."
    exit 1
  fi

  (
    config::substitute_env_vars "${COMPOSE_FILE_PATH}"/config.ini

    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.yml"
    docker::deploy_sanity "${SERVICE_NAMES}"
  ) || {
    log error "Failed to deploy Message $PACKAGE_NAME package, does your .env file include all environment variables in your config.ini file?"
    exit 1
  }
}

function destroy_package() {
  docker::service_destroy "$SERVICE_NAMES"

  docker::prune_configs "ofelia"
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
    log info "Scaling down Message $PACKAGE_NAME"

    docker::scale_services_down "$SERVICE_NAMES"
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying Message $PACKAGE_NAME"

    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
