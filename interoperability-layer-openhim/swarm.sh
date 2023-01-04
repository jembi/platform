#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare mongo_services=()
declare service_names=()
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

  mongo_services=(
    "mongo-1"
  )
  if [[ "${NODE_MODE}" == "cluster" ]]; then
    for i in {2..3}; do
      mongo_services=(
        "${mongo_services[@]}"
        "mongo-$i"
      )
    done
  fi

  service_names=(
    "${mongo_services[@]}"
    "${OPENHIM_SERVICES[@]}"
  )

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly mongo_services
  readonly service_names
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
    package::log info "Running package in DEV mode"
    mongo_dev_compose_filename="docker-compose-mongo.dev.yml"
    openhim_dev_compose_filename="docker-compose.dev.yml"
  else
    package::log info "Running package in PROD mode"
  fi

  if [[ "${NODE_MODE}" == "cluster" ]]; then
    mongo_cluster_compose_filename="docker-compose-mongo.cluster.yml"
  fi

  (
    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose-mongo.yml" "$mongo_cluster_compose_filename" "$mongo_dev_compose_filename"
    docker::deploy_sanity "${mongo_services[@]}"

    if [[ "${NODE_MODE}" == "cluster" ]]; then
      try "${COMPOSE_FILE_PATH}/initiate-replica-set.sh" throw "Fatal: Initiate Mongo replica set failed"
    fi

    prepare_console_config

    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.yml" "$openhim_dev_compose_filename"
    docker::deploy_sanity "${OPENHIM_SERVICES[@]}"

    log info "Waiting OpenHIM Core to be running and responding"
    config::await_service_running "openhim-core" "${COMPOSE_FILE_PATH}"/docker-compose.await-helper.yml "${OPENHIM_CORE_INSTANCES}"
  ) ||
    {
      log error "Failed to deploy Interoperability Layer OpenHIM package"
      exit 1
    }

  if [[ "${ACTION}" == "init" ]]; then
    docker::deploy_config_importer "$COMPOSE_FILE_PATH/importer/docker-compose.config.yml" "interoperability-layer-openhim-config-importer" "openhim"
  fi
}

function scale_services_down() {
  for service_name in "${service_names[@]}"; do
    try \
      "docker service scale instant_$service_name=0" \
      catch \
      "Failed to scale down $service_name"
  done
}

function destroy_package() {
  docker::service_destroy interoperability-layer-openhim-config-importer
  docker::service_destroy await-helper

  for service_name in "${service_names[@]}"; do
    docker::service_destroy "$service_name"
  done

  docker::try_remove_volume openhim-mongo-01

  if [[ "${NODE_MODE}" == "cluster" ]]; then
    log warn "Volumes are only deleted on the host on which the command is run. Mongo volumes on other nodes are not deleted"
  fi

  docker::prune_configs "openhim"
}

main() {
  init_vars "$@"
  import_sources

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    log info "Running Interoperability Layer OpenHIM package in ${NODE_MODE} node mode"

    initialize_package
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down Interoperability Layer OpenHIM"

    scale_services_down
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying Interoperability Layer OpenHIM"

    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
