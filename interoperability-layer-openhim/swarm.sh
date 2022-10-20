#!/bin/bash

# Constants
readonly ACTION=$1
readonly MODE=$2

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)
readonly COMPOSE_FILE_PATH

# Import libraries
ROOT_PATH="${COMPOSE_FILE_PATH}/.."
. "${ROOT_PATH}/utils/config-utils.sh"
. "${ROOT_PATH}/utils/docker-utils.sh"
. "${ROOT_PATH}/utils/log.sh"

verify_core() {
  local start_time
  start_time=$(date +%s)
  until [[ $(docker service ls -f name=instant_openhim-core --format "{{.Replicas}}") == *"${OPENHIM_CORE_INSTANCES}/${OPENHIM_CORE_INSTANCES}"* ]]; do
    config::timeout_check "${start_time}" "openhim-core to start"
    sleep 1
  done

  local await_helper_state
  await_helper_state=$(docker service ps instant_await-helper --format "{{.CurrentState}}")
  until [[ "${await_helper_state}" == *"Complete"* ]]; do
    config::timeout_check "${start_time}" "openhim-core heartbeat check"
    sleep 1

    await_helper_state=$(docker service ps instant_await-helper --format "{{.CurrentState}}")
    if [[ "${await_helper_state}" == *"Failed"* ]] || [[ "${await_helper_state}" == *"Rejected"* ]]; then
      log error "Fatal: Received error when trying to verify state of openhim-core. Error:
       $(docker service ps instant_await-helper --no-trunc --format '{{.Error}}')"
      exit 1
    fi
  done

  try "docker service rm instant_await-helper" "Failed to remove await helper"
}

verify_mongos() {
  log info 'Waiting to ensure all the mongo instances for the replica set are up and running'
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

prepare_console_config() {
  # Set host in OpenHIM console config
  sed -i "s/localhost/${OPENHIM_CORE_MEDIATOR_HOSTNAME}/g; s/8080/${OPENHIM_MEDIATOR_API_PORT}/g" /instant/interoperability-layer-openhim/importer/volume/default.json
}

main() {
  if [[ "${STATEFUL_NODES}" == "cluster" ]]; then
    log info "Running Interoperability Layer OpenHIM package in Cluster node mode"
    mongo_cluster_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose-mongo.cluster.yml"
  else
    log info "Running Interoperability Layer OpenHIM package in Single node mode"
    mongo_cluster_compose_param=""
  fi

  if [[ "${MODE}" == "dev" ]]; then
    log info "Running Interoperability Layer OpenHIM package in DEV mode"
    local mongo_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose-mongo.dev.yml"
    local openhim_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
  else
    log info "Running Interoperability Layer OpenHIM package in PROD mode"
    local mongo_dev_compose_param=""
    local openhim_dev_compose_param=""
  fi

  if [[ "${ACTION}" == "init" ]]; then
    config::set_config_digests "${COMPOSE_FILE_PATH}"/docker-compose.yml
    config::set_config_digests "${COMPOSE_FILE_PATH}"/importer/docker-compose.config.yml

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose-mongo.yml $mongo_cluster_compose_param $mongo_dev_compose_param --with-registry-auth instant" "Failed to deploy mongo"

    if [[ "${STATEFUL_NODES}" == "cluster" ]]; then
      try "${COMPOSE_FILE_PATH}/initiateReplicaSet.sh" "Fatal: Initate Mongo replica set failed."
    fi

    prepare_console_config

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml -c ${COMPOSE_FILE_PATH}/docker-compose.stack-0.yml $openhim_dev_compose_param --with-registry-auth instant" "Failed to create stack-0 openhim core/console"

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.await-helper.yml --with-registry-auth instant" "Failed to deploy await-helper"

    log info "Waiting to give OpenHIM Core time to start up before OpenHIM Console run"
    verify_core

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml -c ${COMPOSE_FILE_PATH}/docker-compose.stack-1.yml $openhim_dev_compose_param --with-registry-auth instant" "Failed to create stack-1 openhim core/console"

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/importer/docker-compose.config.yml --with-registry-auth instant" "Failed to deploy config importer"

    log info "Waiting to give core config importer time to run before cleaning up service"

    config::remove_config_importer interoperability-layer-openhim-config-importer

    # Ensure config importer is removed
    config::await_service_removed instant_interoperability-layer-openhim-config-importer

    log info "Removing stale configs..."
    config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/docker-compose.yml "openhim"
    config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml "openhim"
  elif [[ "${ACTION}" == "up" ]]; then
    config::set_config_digests "$COMPOSE_FILE_PATH"/docker-compose.yml
    config::set_config_digests "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose-mongo.yml $mongo_cluster_compose_param $mongo_dev_compose_param --with-registry-auth instant" "Failed to deploy mongo"
    verify_mongos
    prepare_console_config

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml -c ${COMPOSE_FILE_PATH}/docker-compose.stack-1.yml $openhim_dev_compose_param --with-registry-auth instant" "Failed to create stack-1 openhim core/console"

    log info "Removing stale configs..."
    config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/docker-compose.yml "openhim"
    config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml "openhim"
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down services..."
    try "docker service scale instant_openhim-core=0 instant_openhim-console=0 instant_mongo-1=0" "Error scaling down services"

    if [[ "${STATEFUL_NODES}" == "cluster" ]]; then
      try "docker service scale instant_mongo-2=0 instant_mongo-3=0" "Error scaling down services"
    fi
    log info "Done scaling down services"
  elif [[ "${ACTION}" == "destroy" ]]; then
    docker::service_destroy openhim-core
    docker::service_destroy openhim-console
    docker::service_destroy mongo-1
    docker::service_destroy await-helper
    docker::service_destroy interoperability-layer-openhim-config-importer

    docker::try_remove_volume openhim-mongo1

    if [[ "${STATEFUL_NODES}" == "cluster" ]]; then
      log info "Volumes are only deleted on the host on which the command is run. Mongo volumes on other nodes are not deleted"

      docker::service_destroy mongo-2
      docker::service_destroy mongo-3

      docker::try_remove_volume openhim-mongo2
      docker::try_remove_volume openhim-mongo3
    fi

    # shellcheck disable=SC2046 # intentional word splitting
    docker::prune_configs "openhim"

  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
