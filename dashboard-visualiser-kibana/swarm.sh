#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare NODE_MODE_PREFIX=""
declare SERVICE_NAMES=""

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  SERVICE_NAMES="dashboard-visualiser-kibana"

  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    NODE_MODE_PREFIX="-cluster"
  fi

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly NODE_MODE_PREFIX
  readonly SERVICE_NAMES
}

# shellcheck disable=SC1091
function import_sources() {
  source "${UTILS_PATH}/docker-utils.sh"
  source "${UTILS_PATH}/config-utils.sh"
  source "${UTILS_PATH}/log.sh"
}

function check_elastic() {
  if [[ ! $(docker::get_current_service_status "$ES_LEADER_NODE") == *"Running"* ]]; then
    log error "FATAL: Elasticsearch is not running, Kibana is dependant on it\n"
    exit 1
  fi
}

function initialize_package() {
  local kibana_dev_compose_filename=""
  if [[ "${MODE}" == "dev" ]]; then
    log info "Running package in DEV mode"
    kibana_dev_compose_filename="docker-compose.dev.yml"
  else
    log info "Running package in PROD mode"
  fi

  (
    check_elastic

    export KIBANA_YML_CONFIG="kibana-kibana$NODE_MODE_PREFIX.yml"

    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.yml" "$kibana_dev_compose_filename"
    docker::deploy_sanity "$SERVICE_NAMES"
  ) || {
    log error "Failed to deploy package"
    exit 1
  }

  config::await_network_join "instant_dashboard-visualiser-kibana"

  docker::deploy_config_importer "$COMPOSE_FILE_PATH/importer/docker-compose.config.yml" "kibana-config-importer" "kibana"
}

function destroy_package() {
  docker::service_destroy "$SERVICE_NAMES" "kibana-config-importer" "await-helper"

  docker::prune_configs "kibana"
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

    docker::scale_services_down "${SERVICE_NAMES}"
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying package"
    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
