#!/bin/bash

declare ACTION=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare STACK="reprocess-mediator"
declare MODE=""

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  readonly ACTION
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly STACK
  readonly MODE
}

# shellcheck disable=SC1091
function import_sources() {
  source "${UTILS_PATH}/docker-utils.sh"
  source "${UTILS_PATH}/log.sh"
}

function initialize_package() {
  local reprocess_dev_compose_filename=""

  if [[ "${MODE}" == "dev" ]]; then
    log info "Running package in DEV mode"
    reprocess_dev_compose_filename="docker-compose.dev.yml"
  else
    log info "Running package in PROD mode"
  fi

  (
    docker::deploy_service $STACK "${COMPOSE_FILE_PATH}" "docker-compose.yml" "$reprocess_dev_compose_filename"
  ) || {
    log error "Failed to deploy package"
    exit 1
  }
}

function destroy_package() {
  docker::stack_destroy $STACK

  docker::prune_configs "reprocess-mediator"
}

main() {
  init_vars "$@"
  import_sources

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
}

main "$@"
