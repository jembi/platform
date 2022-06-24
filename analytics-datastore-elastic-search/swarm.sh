#!/bin/bash

ACTION=$1
MODE=$2

STATEFUL_NODES=${STATEFUL_NODES:-"cluster"}

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)

BASHLOG_FILE_PATH=${BASHLOG_FILE_PATH:-"/tmp/logs/platform.log"}

# Import libraries
ROOT_PATH="${COMPOSE_FILE_PATH}/.."
. "${ROOT_PATH}/utils/config-utils.sh"
. "${ROOT_PATH}/utils/docker-utils.sh"
. "${ROOT_PATH}/utils/log.sh"

install_expect() {
  log default "Installing Expect..."
  # >/dev/null 2>&1 throws all terminal input and output text away
  apt-get install -y expect >/dev/null 2>&1
  if [[ $? -eq 1 ]]; then
    log error "Fatal: Failed to install Expect library. Cannot update Elastic Search passwords"
    exit 1
  fi
}

set_elasticsearch_passwords() {
  log default "Setting passwords..."
  local elasticSearchContainerId=""
  elasticSearchContainerId=$(docker ps -qlf name=instant_analytics-datastore-elastic-search)
  "$COMPOSE_FILE_PATH"/set-elastic-passwords.exp "$elasticSearchContainerId" >$BASHLOG_FILE_PATH 2>&1
  if [[ $? -eq 1 ]]; then
    log error "Fatal: Failed to set elastic passwords. Cannot update Elastic Search passwords"
    exit 1
  fi
}

import_elastic_index() {
  # TODO: (castelloG) [PLAT-255] Add support for multiple index imports
  config::set_config_digests "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml
  docker stack deploy -c "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml instant 2>&1
  config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml "elastic-search"
  config::remove_config_importer elastic-search-config-importer
}

if [[ "$STATEFUL_NODES" == "cluster" ]]; then
  log default "Running Analytics Datastore Elastic Search package in Cluster node mode"
  ElasticSearchClusterComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.cluster.yml"
else
  log default "Running Analytics Datastore Elastic Search package in Single node mode"
  ElasticSearchClusterComposeParam=""
fi

if [[ "$MODE" == "dev" ]]; then
  log default "Running Analytics Datastore Elastic Search package in DEV mode"
  ElasticSearchDevComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  log default "Running Analytics Datastore Elastic Search package in PROD mode"
  ElasticSearchDevComposeParam=""
fi

if [[ "$ACTION" == "init" ]]; then
  docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $ElasticSearchClusterComposeParam $ElasticSearchDevComposeParam instant &&
    log default "${prev_cmd}" ||
    log error "${prev_cmd}"

  log default "Waiting for elasticsearch to start before automatically setting built-in passwords..."
  docker::await_container_startup analytics-datastore-elastic-search
  docker::await_container_status analytics-datastore-elastic-search running

  install_expect
  set_elasticsearch_passwords

  import_elastic_index

  log default "Done"
elif [[ "$ACTION" == "up" ]]; then
  docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $ElasticSearchClusterComposeParam $ElasticSearchDevComposeParam instant &&
    log debug "${prev_cmd}" ||
    log error "${prev_cmd}"
elif [[ "$ACTION" == "down" ]]; then
  docker service scale instant_analytics-datastore-elastic-search=0 &&
    log debug "${prev_cmd}" ||
    log error "${prev_cmd}"
elif [[ "$ACTION" == "destroy" ]]; then
  docker service rm instant_analytics-datastore-elastic-search

  docker::await_container_destroy analytics-datastore-elastic-search

  docker volume rm instant_es-data

  if [[ "$STATEFUL_NODES" == "cluster" ]]; then
    log warn "Volumes are only deleted on the host on which the command is run. Elastic Search volumes on other nodes are not deleted"
  fi
else
  log error "Valid options are: init, up, down, or destroy"
fi
