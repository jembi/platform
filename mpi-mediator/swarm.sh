#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare service_name=""

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  service_name="mpi-mediator"

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly service_name
}

# shellcheck disable=SC1091
function import_sources() {
  source "${UTILS_PATH}/docker-utils.sh"
  source "${UTILS_PATH}/log.sh"
}

function initialize_package() {
  local mpi_mediator_dev_compose_filename=""

  if [[ "${MODE}" == "dev" ]]; then
    log info "Running OpenHIM-MPI Mediator package in DEV mode"
    mpi_mediator_dev_compose_filename="docker-compose.dev.yml"
  else
    log info "Running OpenHIM-MPI Mediator package in PROD mode"
  fi

  (
    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.yml" "$mpi_mediator_dev_compose_filename"
    docker::deploy_sanity "${service_name}"
  ) || {
    log error "Failed to deploy OpenHIM-MPI Mediator package"
    exit 1
  }
}

function scale_services_down() {
  try \
    "docker service scale instant_$service_name=0" \
    catch \
    "Failed to scale down $service_name"
}

function destroy_package() {
  docker::service_destroy "$service_name"
}

main() {
  init_vars "$@"
  import_sources

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    log info "Running OpenHIM-MPI Mediator package in ${NODE_MODE} node mode"

    initialize_package
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down OpenHIM-MPI Mediator"

    scale_services_down
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying OpenHIM-MPI Mediator"

    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
