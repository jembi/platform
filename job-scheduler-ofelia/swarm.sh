#!/bin/bash

declare ACTION=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare service_name=""

function init_vars() {
  ACTION=$1

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  service_name="job-scheduler-ofelia"

  readonly ACTION
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly service_name
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
    docker::deploy_sanity "${service_name}"
  ) || {
    log error "Failed to deploy Message Job Scheduler Ofelia package, does your .env file include all environment variables in your config.ini file?"
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

  docker::prune_configs "ofelia"
}

main() {
  init_vars "$@"
  import_sources

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    log info "Running Message Job Scheduler Ofelia package"

    initialize_package
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down Message Job Scheduler Ofelia"

    scale_services_down
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying Message Job Scheduler Ofelia"

    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
