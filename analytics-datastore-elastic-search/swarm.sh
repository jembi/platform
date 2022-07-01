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
  local container=$1
  log info "Setting passwords..."
  local elasticSearchContainerId=""
  elasticSearchContainerId=$(docker ps -qlf name=${container})
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
  LeaderNode="analytics-datastore-elastic-search-01"
else
  log info "Running Analytics Datastore Elastic Search package in Single node mode"
  ElasticSearchClusterComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.yml"
  LeaderNode="analytics-datastore-elastic-search"
fi

if [[ "$MODE" == "dev" ]]; then
  log info "Running Analytics Datastore Elastic Search package in DEV mode"
  ElasticSearchDevComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  log info "Running Analytics Datastore Elastic Search package in PROD mode"
  ElasticSearchDevComposeParam=""
fi

create_certs() {
  log info "Creating certificates"
  try "docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.certs.yml instant" "Creating certificates failed"
  docker::await_container_startup create_certs
  local certContainerId=""
  certContainerId=$(docker ps -qlf name=instant_create_certs)

  # TODO Something better than sleep
  sleep 15
  try "docker cp "$certContainerId":/usr/share/elasticsearch/config/certs ." "Copy failed"

  try "docker service rm instant_create_certs" "Error removing instant_create_certs"
}

add_docker_configs() {
  TIMESTAMP="$(date "+%Y%m%d%H%M%S")"
  readonly TIMESTAMP
  log info "Creating configs"
  docker config create --label name=elasticsearch "${TIMESTAMP}-ca.crt" "./certs/ca/ca.crt"
  docker config create --label name=elasticsearch "${TIMESTAMP}-es01.crt" "./certs/es01/es01.crt"
  docker config create --label name=elasticsearch "${TIMESTAMP}-es01.key" "./certs/es01/es01.key"
  docker config create --label name=elasticsearch "${TIMESTAMP}-es02.crt" "./certs/es02/es02.crt"
  docker config create --label name=elasticsearch "${TIMESTAMP}-es02.key" "./certs/es02/es02.key"
  docker config create --label name=elasticsearch "${TIMESTAMP}-es03.crt" "./certs/es03/es03.crt"
  docker config create --label name=elasticsearch "${TIMESTAMP}-es03.key" "./certs/es03/es03.key"

  log info "Updating es-01 with certs"
  if ! docker service update \
    --config-add source="${TIMESTAMP}-ca.crt",target=/usr/share/elasticsearch/config/certs/ca/ca.crt \
    --config-add source="${TIMESTAMP}-es01.crt",target=/usr/share/elasticsearch/config/certs/es01/es01.crt \
    --config-add source="${TIMESTAMP}-es01.key",target=/usr/share/elasticsearch/config/certs/es01/es01.key \
    instant_analytics-datastore-elastic-search-01 >/dev/null; then
    log error "Error updating es01"
    exit 1
  fi
  log info "Updating es-02 with certs"
  if ! docker service update \
    --config-add source="${TIMESTAMP}-ca.crt",target=/usr/share/elasticsearch/config/certs/ca/ca.crt \
    --config-add source="${TIMESTAMP}-es02.crt",target=/usr/share/elasticsearch/config/certs/es02/es02.crt \
    --config-add source="${TIMESTAMP}-es02.key",target=/usr/share/elasticsearch/config/certs/es02/es02.key \
    instant_analytics-datastore-elastic-search-02 >/dev/null; then
    log error "Error updating es02"
    exit 1
  fi
  log info "Updating es-03 with certs"
  if ! docker service update \
    --config-add source="${TIMESTAMP}-ca.crt",target=/usr/share/elasticsearch/config/certs/ca/ca.crt \
    --config-add source="${TIMESTAMP}-es03.crt",target=/usr/share/elasticsearch/config/certs/es03/es03.crt \
    --config-add source="${TIMESTAMP}-es03.key",target=/usr/share/elasticsearch/config/certs/es03/es03.key \
    instant_analytics-datastore-elastic-search-03 >/dev/null; then
    log error "Error updating es03"
    exit 1
  fi
}

if [[ "$ACTION" == "init" ]]; then
  if [[ "$STATEFUL_NODES" == "cluster" ]]; then
    create_certs
    try "docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.cluster.yml instant" "Failed to deploy cluster"
    add_docker_configs
  else
    try "docker stack deploy $ElasticSearchClusterComposeParam $ElasticSearchDevComposeParam instant" "Failed to deploy Analytics Datastore Elastic Search"
  fi

  log info "Waiting for elasticsearch to start before automatically setting built-in passwords"
  docker::await_container_startup $LeaderNode
  docker::await_container_status $LeaderNode running

  install_expect
  set_elasticsearch_passwords $LeaderNode

  import_elastic_index

  log info "Done"
elif [[ "$ACTION" == "up" ]]; then
  if [[ "$STATEFUL_NODES" == "cluster" ]]; then
    try "docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.cluster.yml instant" "Failed to deploy cluster"
  else
    try "docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $ElasticSearchDevComposeParam instant" "Failed to deploy Analytics Datastore Elastic Search"
  fi
elif [[ "$ACTION" == "down" ]]; then
  if [[ "$STATEFUL_NODES" == "cluster" ]]; then
    try "docker service scale instant_analytics-datastore-elastic-search-01=0" "Failed to scale down analytics-datastore-elastic-search-01"
    try "docker service scale instant_analytics-datastore-elastic-search-02=0" "Failed to scale down analytics-datastore-elastic-search-02"
    try "docker service scale instant_analytics-datastore-elastic-search-03=0" "Failed to scale down analytics-datastore-elastic-search-03"
  else
    try "docker service scale instant_analytics-datastore-elastic-search=0" "Failed to scale down analytics-datastore-elastic-search"
  fi
elif [[ "$ACTION" == "destroy" ]]; then
  if [[ "$STATEFUL_NODES" == "cluster" ]]; then
    try "docker service rm instant_analytics-datastore-elastic-search-01" "Failed to remove analytics-datastore-elastic-search-01"
    try "docker service rm instant_analytics-datastore-elastic-search-02" "Failed to remove analytics-datastore-elastic-search-02"
    try "docker service rm instant_analytics-datastore-elastic-search-03" "Failed to remove analytics-datastore-elastic-search-03"

    docker::await_container_destroy analytics-datastore-elastic-search-01
    docker::await_container_destroy analytics-datastore-elastic-search-02
    docker::await_container_destroy analytics-datastore-elastic-search-03

    log warn "Volumes are only deleted on the host on which the command is run. Elastic Search volumes on other nodes are not deleted"
  else
    try "docker service rm instant_analytics-datastore-elastic-search" "Failed to remove analytics-datastore-elastic-search"
    docker::await_container_destroy analytics-datastore-elastic-search
    try "docker volume rm instant_es-data" "Failed to remove volume instant_es-data"
  fi
else
  log error "Valid options are: init, up, down, or destroy"
fi
