#!/bin/bash

Action=$1
Mode=$2

STATEFUL_NODES=${STATEFUL_NODES:-"cluster"}

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)

# Import libraries
ROOT_PATH="${COMPOSE_FILE_PATH}/.."
. "${ROOT_PATH}/utils/config-utils.sh"
. "${ROOT_PATH}/utils/docker-utils.sh"
. "${ROOT_PATH}/utils/log.sh"

await_container_ready() {
  log info "Waiting for analytics-datastore-elastic-search to be in ready state..."
  local start_time
  start_time=$(date +%s)
  until [[ "$(docker inspect -f '{{.State.Status}}' $(docker ps -qlf name=instant_analytics-datastore-elastic-search))" = "running" ]]; do
    config::timeout_check "${start_time}" "analytics-datastore-elastic-search to start"
    sleep 1
  done
}

InstallExpect() {
  log info "Installing Expect..."
  # >/dev/null 2>&1 throws all terminal input and output text away
  apt-get install -y expect >/dev/null 2>&1
  if [[ $? -eq 1 ]]; then
    log error "Fatal: Failed to install Expect library. Cannot update Elastic Search passwords"
    exit 1
  fi
}

SetElasticsearchPasswords() {
  log info "Setting passwords..."
  local elasticSearchContainerId=""
  elasticSearchContainerId=$(docker ps -qlf name=instant_analytics-datastore-elastic-search)
  "$COMPOSE_FILE_PATH"/set-elastic-passwords.exp "$elasticSearchContainerId" >/dev/null 2>&1
  if [[ $? -eq 1 ]]; then
    log error "Fatal: Failed to set elastic passwords. Cannot update Elastic Search passwords"
    exit 1
  fi
}

await_container_destroy() {
  log info "Waiting for analytics-datastore-elastic-search to be destroyed..."
  local start_time
  start_time=$(date +%s)
  until [[ -z $(docker ps -qlf name=instant_analytics-datastore-elastic-search) ]]; do
    config::timeout_check "${start_time}" "analytics-datastore-elastic-search to start"
    sleep 1
  done
}

ImportElasticIndex() {
  # TODO: (castelloG) [PLAT-255] Add support for multiple index imports
  config::set_config_digests "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml
  docker stack deploy -c "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml instant
  config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml "elastic-search"
  config::remove_config_importer elastic-search-config-importer
}

if [[ "$STATEFUL_NODES" == "cluster" ]]; then
  log info "Running Analytics Datastore Elastic Search package in Cluster node mode"
  ElasticSearchClusterComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.cluster.yml"
else
  log info "Running Analytics Datastore Elastic Search package in Single node mode"
  ElasticSearchClusterComposeParam=""
fi

if [[ "$Mode" == "dev" ]]; then
  log info "Running Analytics Datastore Elastic Search package in DEV mode"
  ElasticSearchDevComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  log info "Running Analytics Datastore Elastic Search package in PROD mode"
  ElasticSearchDevComposeParam=""
fi

if [[ "$Action" == "init" ]]; then
  docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $ElasticSearchClusterComposeParam $ElasticSearchDevComposeParam instant

  log info "Waiting for elasticsearch to start before automatically setting built-in passwords..."
  docker::await_container_startup analytics-datastore-elastic-search
  await_container_ready

  InstallExpect
  SetElasticsearchPasswords

  ImportElasticIndex

  log info "Done initialising"
elif [[ "$Action" == "up" ]]; then
  docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $ElasticSearchClusterComposeParam $ElasticSearchDevComposeParam instant
elif [[ "$Action" == "down" ]]; then
  docker service scale instant_analytics-datastore-elastic-search=0
elif [[ "$Action" == "destroy" ]]; then
  docker service rm instant_analytics-datastore-elastic-search

  await_container_destroy

  docker volume rm instant_es-data

  if [[ "$STATEFUL_NODES" == "cluster" ]]; then
    log warn "Volumes are only deleted on the host on which the command is run. Elastic Search volumes on other nodes are not deleted"
  fi
else
  log error "Valid options are: init, up, down, or destroy"
fi
