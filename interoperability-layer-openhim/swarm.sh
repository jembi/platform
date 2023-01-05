#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare MONGO_SERVICES=()
declare SERVICE_NAMES=()
declare OPENHIM_SERVICES=()

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  OPENHIM_SERVICES=(
    "openhim-core"
    "openhim-console"
  )

  MONGO_SERVICES=(
    "mongo-1"
  )
  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    for i in {2..3}; do
      MONGO_SERVICES=(
        "${MONGO_SERVICES[@]}"
        "mongo-$i"
      )
    done
  fi

  SERVICE_NAMES=(
    "${MONGO_SERVICES[@]}"
    "${OPENHIM_SERVICES[@]}"
  )

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly MONGO_SERVICES
  readonly SERVICE_NAMES
}

# shellcheck disable=SC1091
function import_sources() {
  source "${UTILS_PATH}/docker-utils.sh"
  source "${UTILS_PATH}/config-utils.sh"
  source "${UTILS_PATH}/log.sh"
}

function prepare_console_config() {
  # Set host in OpenHIM console config
  sed -i "s/localhost/${OPENHIM_CORE_MEDIATOR_HOSTNAME}/g; s/8080/${OPENHIM_MEDIATOR_API_PORT}/g" /instant/interoperability-layer-openhim/importer/volume/default.json
}

function initialize_package() {
  local mongo_cluster_compose_filename=""
  local mongo_dev_compose_filename=""
  local openhim_dev_compose_filename=""

  if [[ "${MODE}" == "dev" ]]; then
    log info "Running Interoperability Layer OpenHIM package in DEV mode"
    mongo_dev_compose_filename="docker-compose-mongo.dev.yml"
    openhim_dev_compose_filename="docker-compose.dev.yml"
  else
    log info "Running Interoperability Layer OpenHIM package in PROD mode"
  fi

  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    mongo_cluster_compose_filename="docker-compose-mongo.cluster.yml"
  fi

  (
    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose-mongo.yml" "$mongo_cluster_compose_filename" "$mongo_dev_compose_filename"

    if [[ "${CLUSTERED_MODE}" == "true" ]] && [[ "${ACTION}" == "init" ]]; then
      try "${COMPOSE_FILE_PATH}/initiate-replica-set.sh" throw "Fatal: Initiate Mongo replica set failed"
    fi
    docker::deploy_sanity "${MONGO_SERVICES[@]}"

    prepare_console_config

    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.yml" "$openhim_dev_compose_filename"
    docker::deploy_sanity "${OPENHIM_SERVICES[@]}"

    log info "Waiting OpenHIM Core to be running and responding"
    config::await_service_running "openhim-core" "${COMPOSE_FILE_PATH}"/docker-compose.await-helper.yml "${OPENHIM_CORE_INSTANCES}"
  ) ||
    {
      log error "Failed to deploy package"
      exit 1
    }

  if [[ "${ACTION}" == "init" ]]; then
    docker::deploy_config_importer "$COMPOSE_FILE_PATH/importer/docker-compose.config.yml" "interoperability-layer-openhim-config-importer" "openhim"
  fi
}

function destroy_package() {
  docker::service_destroy "${SERVICE_NAMES[@]}" "interoperability-layer-openhim-config-importer" "await-helper"

  docker::try_remove_volume openhim-mongo-01

  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    log warn "Volumes are only deleted on the host on which the command is run. Mongo volumes on other nodes are not deleted"
  fi

  docker::prune_configs "openhim"
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

    docker::scale_services_down "${SERVICE_NAMES[@]}"
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying package"
    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
