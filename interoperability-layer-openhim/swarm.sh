#!/bin/bash

# Constants
readonly ACTION=$1
readonly MODE=$2
readonly STATEFUL_NODES=${STATEFUL_NODES:-"cluster"}
readonly OPENHIM_CORE_MEDIATOR_HOSTNAME=${OPENHIM_CORE_MEDIATOR_HOSTNAME:-"localhost"}
readonly OPENHIM_MEDIATOR_API_PORT=${OPENHIM_MEDIATOR_API_PORT:-"8080"}
readonly OPENHIM_CORE_INSTANCES=${OPENHIM_CORE_INSTANCES:-1}
readonly OPENHIM_CONSOLE_INSTANCES=${OPENHIM_CONSOLE_INSTANCES:-1}
readonly MONGO_SET_COUNT=${MONGO_SET_COUNT:-3}

TIMESTAMP="$(date "+%Y%m%d%H%M%S")"
readonly TIMESTAMP

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

remove_config_importer() {
  local start_time
  start_time=$(date +%s)
  local config_importer_state
  config_importer_state=$(docker service ps instant_interoperability-layer-openhim-config-importer --format "{{.CurrentState}}")
  until [[ "${config_importer_state}" == *"Complete"* ]]; do
    config::timeout_check "${start_time}" "interoperability-layer-openhim-config-importer to run"
    sleep 1

    config_importer_state=$(docker service ps instant_interoperability-layer-openhim-config-importer --format "{{.CurrentState}}")
    if [[ "${config_importer_state}" == *"Failed"* ]] || [[ ${config_importer_state} == *"Rejected"* ]]; then
      log error "Fatal: Core config importer failed with error:
       $(docker service ps instant_interoperability-layer-openhim-config-importer --no-trunc --format '{{.Error}}')"
      exit 1
    fi
  done

  try "docker service rm instant_interoperability-layer-openhim-config-importer" "Failed to remove config importer"
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

configure_nginx() {
  if [[ "${INSECURE}" == "true" ]]; then
    try "docker config create --label name=nginx ${TIMESTAMP}-http-openhim-insecure.conf ${COMPOSE_FILE_PATH}/config/http-openhim-insecure.conf" "Failed to add openhim nginx insecure config"
    try "docker config create --label name=nginx ${TIMESTAMP}-stream-openhim-insecure.conf ${COMPOSE_FILE_PATH}/config/stream-openhim-insecure.conf" "Failed to add openhim nginx insecure config"
    log info "Updating nginx service: adding openhim config file..."
    try "docker service update --config-add source=${TIMESTAMP}-http-openhim-insecure.conf,target=/etc/nginx/conf.d/http-openhim-insecure.conf --config-add source=${TIMESTAMP}-stream-openhim-insecure.conf,target=/etc/nginx/conf.d/stream-openhim-insecure.conf instant_reverse-proxy-nginx" "Error updating nginx service"
    log info "Done updating nginx service"
  else
    try "docker config create --label name=nginx ${TIMESTAMP}-http-openhim-secure.conf ${COMPOSE_FILE_PATH}/config/http-openhim-secure.conf" "Failed to add openhim nginx secure config"
    log info "Updating nginx service: adding openhim config file..."
    try "docker service update --config-add source=${TIMESTAMP}-http-openhim-secure.conf,target=/etc/nginx/conf.d/http-openhim-secure.conf instant_reverse-proxy-nginx" "Error updating nginx service"
    log info "Done updating nginx service"
  fi
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

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose-mongo.yml $mongo_cluster_compose_param $mongo_dev_compose_param instant" "Failed to deploy mongo"

    if [[ "${STATEFUL_NODES}" == "cluster" ]]; then
      try "${COMPOSE_FILE_PATH}/initiateReplicaSet.sh" "Fatal: Initate Mongo replica set failed."
    fi

    prepare_console_config

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml -c ${COMPOSE_FILE_PATH}/docker-compose.stack-0.yml $openhim_dev_compose_param instant" "Failed to create stack-0 openhim core/console"

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.await-helper.yml instant" "Failed to deploy await-helper"

    log info "Waiting to give OpenHIM Core time to start up before OpenHIM Console run"
    verify_core

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml -c ${COMPOSE_FILE_PATH}/docker-compose.stack-1.yml $openhim_dev_compose_param instant" "Failed to create stack-1 openhim core/console"

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/importer/docker-compose.config.yml instant" "Failed to deploy config importer"

    log info "Waiting to give core config importer time to run before cleaning up service"
    remove_config_importer

    # Ensure config importer is removed
    config::await_service_removed instant_interoperability-layer-openhim-config-importer

    log info "Removing stale configs..."
    config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/docker-compose.yml "openhim"
    config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml "openhim"

    if [[ "${MODE}" != "dev" ]]; then
      configure_nginx "$@"
    fi
  elif [[ "${ACTION}" == "up" ]]; then
    config::set_config_digests "$COMPOSE_FILE_PATH"/docker-compose.yml
    config::set_config_digests "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose-mongo.yml $mongo_cluster_compose_param $mongo_dev_compose_param instant" "Failed to deploy mongo"
    verify_mongos
    prepare_console_config

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml -c ${COMPOSE_FILE_PATH}/docker-compose.stack-1.yml $openhim_dev_compose_param instant" "Failed to create stack-1 openhim core/console"

    log info "Removing stale configs..."
    config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/docker-compose.yml "openhim"
    config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml "openhim"

    if [[ "${MODE}" != "dev" ]]; then
      configure_nginx "$@"
    fi
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down services..."
    try "docker service scale instant_openhim-core=0 instant_openhim-console=0 instant_mongo-1=0" "Error scaling down services"

    if [[ "${STATEFUL_NODES}" == "cluster" ]]; then
      try "docker service scale instant_mongo-2=0 instant_mongo-3=0" "Error scaling down services"
    fi
    log info "Done scaling down services"
  elif [[ "${ACTION}" == "destroy" ]]; then
    try "docker service rm instant_openhim-core instant_openhim-console instant_mongo-1 instant_await-helper instant_interoperability-layer-openhim-config-importer" "Failed to remove interoperability-layer-openhim"

    config::await_service_removed instant_openhim-core
    config::await_service_removed instant_openhim-console
    config::await_service_removed instant_mongo-1
    config::await_service_removed instant_await-helper
    config::await_service_removed instant_interoperability-layer-openhim-config-importer

    try "docker volume rm instant_openhim-mongo1" "Failed to remove openhim-mongo1 volume"

    # shellcheck disable=SC2046 # intentional word splitting
    try "docker config rm $(docker config ls -qf label=name=openhim)" "Failed to remove configs"

    if [[ "${STATEFUL_NODES}" == "cluster" ]]; then
      log info "Volumes are only deleted on the host on which the command is run. Mongo volumes on other nodes are not deleted"

      try "docker service rm instant_mongo-2 instant_mongo-3" "Failed to remove mongo cluster"
      config::await_service_removed instant_mongo-2
      config::await_service_removed instant_mongo-3
      try "docker volume rm instant_openhim-mongo2 instant_openhim-mongo3" "Failed to remove mongo volumes"

      # shellcheck disable=SC2046 # intentional word splitting
      try "docker config rm $(docker config ls -qf label=name=openhim)" "Failed to remove openhim configs"
    fi

  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
