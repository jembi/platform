#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare STACK="openhim"

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  readonly ACTION
  readonly MODE
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
  local mongo_cluster_compose_filename=""
  local mongo_dev_compose_filename=""
  local openhim_dev_compose_filename=""

  if [[ "${MODE}" == "dev" ]]; then
    log info "Running package in DEV mode"
    mongo_dev_compose_filename="docker-compose-mongo.dev.yml"
    openhim_dev_compose_filename="docker-compose.dev.yml"
  else
    log info "Running package in PROD mode"
  fi

  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    mongo_cluster_compose_filename="docker-compose-mongo.cluster.yml"
  fi

  (
    docker::deploy_service $STACK "${COMPOSE_FILE_PATH}" "docker-compose-mongo.yml" "$mongo_cluster_compose_filename" "$mongo_dev_compose_filename"

    if [[ "${ACTION}" == "init" ]]; then
      if [[ "${CLUSTERED_MODE}" == "true" ]]; then
        try "${COMPOSE_FILE_PATH}/initiate-replica-set.sh $STACK" throw "Fatal: Initiate Mongo replica set failed"
      else
        config::await_service_running "mongo-1" "${COMPOSE_FILE_PATH}"/docker-compose.await-helper-mongo.yml "1" "$STACK"

        try "docker exec -i $(docker ps -q -f name=openhim_mongo) mongo --eval \"rs.initiate({'_id': 'mongo-set','members': [{'_id': 0,'priority': 1,'host': 'mongo-1:27017'}]})\"" throw "Could not initiate replica set for the single mongo instance. Some services use \
        mongo event listeners which only work with a replica set"
      fi
    fi

    docker::deploy_service $STACK "${COMPOSE_FILE_PATH}" "docker-compose.yml" "$openhim_dev_compose_filename"

    log info "Waiting OpenHIM Core to be running and responding"
    config::await_service_running "openhim-core" "${COMPOSE_FILE_PATH}"/docker-compose.await-helper.yml "${OPENHIM_CORE_INSTANCES}" "$STACK"
  ) ||
    {
      log error "Failed to deploy package"
      exit 1
    }

  if [[ "${ACTION}" == "init" ]]; then
    docker::deploy_config_importer $STACK "$COMPOSE_FILE_PATH/importer/docker-compose.config.yml" "interoperability-layer-openhim-config-importer" "openhim"
  fi
}

function destroy_package() {
  docker::stack_destroy "$STACK"

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

    docker::scale_services "$STACK" 0
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying package"
    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
