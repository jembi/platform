#!/bin/bash

declare ACTION=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare STACK="ofelia"

function init_vars() {
  ACTION=$1

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  readonly ACTION
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly STACK
}

# shellcheck disable=SC1091
function import_sources() {
  source "${UTILS_PATH}/docker-utils.sh"
  source "${UTILS_PATH}/config-utils.sh"
  source "${UTILS_PATH}/log.sh"
}

function initialize_package() {
  (
    config::substitute_env_vars "${COMPOSE_FILE_PATH}"/config.ini

    docker::deploy_service $STACK "${COMPOSE_FILE_PATH}" "docker-compose.yml"
  ) || {
    log error "Failed to deploy package, does your .env file include all environment variables in your config.ini file?"
    exit 1
  }
}

function destroy_package() {
  docker::stack_destroy $STACK

  docker::prune_configs "ofelia"
}

main() {
  init_vars "$@"
  import_sources

  if [[ ! -f "${COMPOSE_FILE_PATH}/config.ini" ]]; then
    log warn "WARNING: config.ini file does not exist, Aborting..."
  else
    if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
      log info "Running package"

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
  fi

}

main "$@"
