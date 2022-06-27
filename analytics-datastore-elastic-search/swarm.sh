#!/bin/bash

ACTION=$1
MODE=$2

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

install_expect() {
  log info "Installing Expect..."
  try "apt-get install -y expect" "Fatal: Failed to install Expect library. Cannot update Elastic Search passwords"
  overwrite "Installing Expect... Done"
}

set_elasticsearch_passwords() {
  log info "Setting passwords..."
  local elasticSearchContainerId=""
  elasticSearchContainerId=$(docker ps -qlf name=instant_analytics-datastore-elastic-search)
  try "${COMPOSE_FILE_PATH}/set-elastic-passwords.exp ${elasticSearchContainerId}" "Fatal: Failed to set elastic passwords. Cannot update Elastic Search passwords"
  overwrite "Setting passwords... Done"
}

import_elastic_index() {
  # TODO: (castelloG) [PLAT-255] Add support for multiple index imports
  config::set_config_digests "${COMPOSE_FILE_PATH}"/importer/docker-compose.config.yml
  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/importer/docker-compose.config.yml instant" "Failed to start elastic search config importer"
  config::remove_stale_service_configs "${COMPOSE_FILE_PATH}"/importer/docker-compose.config.yml "elastic-search"
  config::remove_config_importer elastic-search-config-importer
}

if [[ "$STATEFUL_NODES" == "cluster" ]]; then
  log info "Running Analytics Datastore Elastic Search package in Cluster node mode"
  ElasticSearchClusterComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.cluster.yml"
else
  log info "Running Analytics Datastore Elastic Search package in Single node mode"
  ElasticSearchClusterComposeParam=""
fi

if [[ "$MODE" == "dev" ]]; then
  log info "Running Analytics Datastore Elastic Search package in DEV mode"
  ElasticSearchDevComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  log info "Running Analytics Datastore Elastic Search package in PROD mode"
  ElasticSearchDevComposeParam=""
fi

if [[ "$ACTION" == "init" ]]; then
  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml $ElasticSearchClusterComposeParam $ElasticSearchDevComposeParam instant" "Failed to deploy Analytics Datastore Elastic Search"

  log info "Waiting for elasticsearch to start before automatically setting built-in passwords"
  docker::await_container_startup analytics-datastore-elastic-search
  docker::await_container_status analytics-datastore-elastic-search running

  install_expect
  set_elasticsearch_passwords

  import_elastic_index

  log info "Done"
elif [[ "$ACTION" == "up" ]]; then
  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml $ElasticSearchClusterComposeParam $ElasticSearchDevComposeParam instant" "Failed to deploy Analytics Datastore Elastic Search"
elif [[ "$ACTION" == "down" ]]; then
  try "docker service scale instant_analytics-datastore-elastic-search=0" "Failed to scale down analytics-datastore-elastic-search"
elif [[ "$ACTION" == "destroy" ]]; then
  try "docker service rm instant_analytics-datastore-elastic-search" "Failed to remove analytics-datastore-elastic-search"

  docker::await_container_destroy analytics-datastore-elastic-search

  try "docker volume rm instant_es-data" "Failed to remove volume instant_es-data"

  if [[ "$STATEFUL_NODES" == "cluster" ]]; then
    log warn "Volumes are only deleted on the host on which the command is run. Elastic Search volumes on other nodes are not deleted"
  fi
else
  log error "Valid options are: init, up, down, or destroy"
fi
