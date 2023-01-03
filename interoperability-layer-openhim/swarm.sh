#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare MONGO_SERVICES=()
declare SERVICE_NAMES=()

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  MONGO_SERVICES=(
    "mongo-1"
  )
  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    for i in {1..3}; do
      MONGO_SERVICES=(
        "${MONGO_SERVICES[@]}"
        "mongo-$i"
      )
    done
  fi

  SERVICE_NAMES=(
    "${MONGO_SERVICES[@]}"
    "openhim-core"
    "openhim-console"
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

function verify_mongos() {
  log info 'Waiting to ensure all the mongo instances for the replica set are up and running...'

  local -i running_instance_count
  running_instance_count=0
  local start_time
  start_time=$(date +%s)

  until [[ "${running_instance_count}" -eq "${MONGO_SET_COUNT}" ]]; do
    config::timeout_check "${start_time}" "mongo set to start"
    sleep 1

    running_instance_count=0
    for i in $(docker service ls -f name=instant_mongo --format "{{.Replicas}}"); do
      if [[ "${i}" == "1/1" ]]; then
        running_instance_count=$((running_instance_count + 1))
      fi
    done
  done
}

function prepare_console_config() {
  # Set host in OpenHIM console config
  sed -i "s/localhost/${OPENHIM_CORE_MEDIATOR_HOSTNAME}/g; s/8080/${OPENHIM_MEDIATOR_API_PORT}/g" /instant/interoperability-layer-openhim/importer/volume/default.json
}

function init_package() {
  (
    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose-mongo.yml" "$mongo_cluster_compose_filename" "$mongo_dev_compose_filename"
    docker::deploy_sanity "${MONGO_SERVICES[@]}"

    if [[ "${CLUSTERED_MODE}" == "true" ]]; then
      try "${COMPOSE_FILE_PATH}/initiate-replica-set.sh" throw "Fatal: Initiate Mongo replica set failed"
    fi

    prepare_console_config

    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.yml" "docker-compose.stack-0.yml" "$openhim_dev_compose_filename"

    log info "Waiting to give OpenHIM Core time to start up before OpenHIM Console run..."
    docker::deploy_sanity "openhim-core"
    config::await_service_running "openhim-core" "${COMPOSE_FILE_PATH}"/docker-compose.await-helper.yml "${OPENHIM_CORE_INSTANCES}"

    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.yml" "docker-compose.stack-1.yml" "$openhim_dev_compose_filename"
    docker::deploy_sanity "openhim-console"
  ) ||
    {
      package::log error "Failed to deploy package"
      exit 1
    }

  docker::deploy_config_importer "$COMPOSE_FILE_PATH/importer/docker-compose.config.yml" "interoperability-layer-openhim-config-importer" "openhim"
}

function scale_services_up() {
  (
    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose-mongo.yml" "$mongo_cluster_compose_filename" "$mongo_dev_compose_filename"
    docker::deploy_sanity "${MONGO_SERVICES[@]}"

    verify_mongos
    prepare_console_config

    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.yml" "docker-compose.stack-1.yml" "$openhim_dev_compose_filename"
    docker::deploy_sanity "openhim-core" "openhim-console"
  ) || {
    package::log error "Failed to scale up package"
    exit 1
  }
}

function start_package() {
  local mongo_cluster_compose_filename=""
  local mongo_dev_compose_filename=""
  local openhim_dev_compose_filename=""

  if [[ "${MODE}" == "dev" ]]; then
    package::log info "Running package in DEV mode"
    local mongo_dev_compose_filename="docker-compose-mongo.dev.yml"
    local openhim_dev_compose_filename="docker-compose.dev.yml"
  else
    package::log info "Running package in PROD mode"
  fi

  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    mongo_cluster_compose_filename="docker-compose-mongo.cluster.yml"
  fi

  if [[ "${ACTION}" == "init" ]]; then

    init_package
  elif [[ "${ACTION}" == "up" ]]; then

    scale_services_up
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
      package::log info "Running package in Cluster node mode"
    else
      package::log info "Running package in Single node mode"
    fi

    start_package
  elif [[ "${ACTION}" == "down" ]]; then
    package::log info "Scaling down package"

    docker::scale_services_down "${SERVICE_NAMES[@]}"
  elif [[ "${ACTION}" == "destroy" ]]; then
    package::log info "Destroying package"
    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
