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
  local elastic_search_container_id=""
  elastic_search_container_id=$(docker ps -qlf name="${container}")
  try "${COMPOSE_FILE_PATH}/set-elastic-passwords.exp ${elastic_search_container_id}" "Fatal: Failed to set elastic passwords. Cannot update Elastic Search passwords"
  overwrite "Setting passwords... Done"
}

import_elastic_index() {
  # TODO: (castelloG) [PLAT-255] Add support for multiple index imports
  log info "Importing Elasticsearch index mapping"
  config::set_config_digests "${COMPOSE_FILE_PATH}"/importer/docker-compose.config.yml
  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/importer/docker-compose.config.yml instant" "Failed to start elastic search config importer"
  config::remove_stale_service_configs "${COMPOSE_FILE_PATH}"/importer/docker-compose.config.yml "elastic-search"
  config::remove_config_importer elastic-search-config-importer
}

if [[ "$STATEFUL_NODES" == "cluster" ]]; then
  log info "Running Analytics Datastore Elastic Search package in Cluster node mode"
  leader_node="analytics-datastore-elastic-search-01"
else
  log info "Running Analytics Datastore Elastic Search package in Single node mode"
  leader_node="analytics-datastore-elastic-search"
fi

if [[ "$MODE" == "dev" ]]; then
  log info "Running Analytics Datastore Elastic Search package in DEV mode"
  elastic_search_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  log info "Running Analytics Datastore Elastic Search package in PROD mode"
  elastic_search_dev_compose_param=""
fi

create_certs() {
  log info "Creating certificates"
  try "docker stack deploy -c $COMPOSE_FILE_PATH/docker-compose.certs.yml instant" "Creating certificates failed"
  docker::await_container_startup create_certs
  docker::await_container_status create_certs exited

  log info "Creating cert helper"

  try "docker run --rm --network host --name es-cert-helper -w /temp \
    -v instant_certgen:/temp-certificates \
    -v instant:/temp busybox sh \
    -c \"mkdir -p /temp/certs; cp -r /temp-certificates/* /temp/certs\"" "Error creating es-cert-helper"

  try "docker service rm instant_create_certs" "Error removing instant_create_certs"
  docker::await_container_destroy create_certs
  docker::await_container_destroy es-cert-helper
  try "docker volume rm instant_certgen" "Error removing certgen volume"
}

add_docker_configs() {
  TIMESTAMP="$(date "+%Y%m%d%H%M%S")"
  readonly TIMESTAMP
  log info "Creating configs"
  try "docker config create --label name=elasticsearch ${TIMESTAMP}-ca.crt ./certs/ca/ca.crt" "Error creating config ca.crt"
  try "docker config create --label name=elasticsearch ${TIMESTAMP}-es01.crt ./certs/es01/es01.crt" "Error creating config es01.crt"
  try "docker config create --label name=elasticsearch ${TIMESTAMP}-es01.key ./certs/es01/es01.key" "Error creating config es01.key"
  try "docker config create --label name=elasticsearch ${TIMESTAMP}-es02.crt ./certs/es02/es02.crt" "Error creating config es02.crt"
  try "docker config create --label name=elasticsearch ${TIMESTAMP}-es02.key ./certs/es02/es02.key" "Error creating config es02.key"
  try "docker config create --label name=elasticsearch ${TIMESTAMP}-es03.crt ./certs/es03/es03.crt" "Error creating config es03.crt"
  try "docker config create --label name=elasticsearch ${TIMESTAMP}-es03.key ./certs/es03/es03.key" "Error creating config es03.key"

  log info "Updating es-01 with certs"
  try "docker service update \
    --config-add source=${TIMESTAMP}-ca.crt,target=/usr/share/elasticsearch/config/certs/ca/ca.crt \
    --config-add source=${TIMESTAMP}-es01.crt,target=/usr/share/elasticsearch/config/certs/es01/es01.crt \
    --config-add source=${TIMESTAMP}-es01.key,target=/usr/share/elasticsearch/config/certs/es01/es01.key \
    instant_analytics-datastore-elastic-search-01" "Error updating es01"

  log info "Updating es-02 with certs"
  try "docker service update \
    --config-add source=${TIMESTAMP}-ca.crt,target=/usr/share/elasticsearch/config/certs/ca/ca.crt \
    --config-add source=${TIMESTAMP}-es02.crt,target=/usr/share/elasticsearch/config/certs/es02/es02.crt \
    --config-add source=${TIMESTAMP}-es02.key,target=/usr/share/elasticsearch/config/certs/es02/es02.key \
    instant_analytics-datastore-elastic-search-02" "Error updating es02"

  log info "Updating es-03 with certs"
  try "docker service update \
    --config-add source=${TIMESTAMP}-ca.crt,target=/usr/share/elasticsearch/config/certs/ca/ca.crt \
    --config-add source=${TIMESTAMP}-es03.crt,target=/usr/share/elasticsearch/config/certs/es03/es03.crt \
    --config-add source=${TIMESTAMP}-es03.key,target=/usr/share/elasticsearch/config/certs/es03/es03.key \
    instant_analytics-datastore-elastic-search-03" "Error updating es03"
}

if [[ "$ACTION" == "init" ]]; then
  if [[ "$STATEFUL_NODES" == "cluster" ]]; then
    create_certs
    try "docker stack deploy -c $COMPOSE_FILE_PATH/docker-compose.cluster.yml instant" "Failed to deploy cluster"
    add_docker_configs
  else
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml $elastic_search_dev_compose_param instant" "Failed to deploy Analytics Datastore Elastic Search"
  fi

  log info "Waiting for elasticsearch to start before automatically setting built-in passwords"
  docker::await_container_status $leader_node running

  install_expect
  set_elasticsearch_passwords $leader_node

  config::await_network_join "instant_analytics-datastore-elastic-search"

  import_elastic_index

  log info "Done"
elif [[ "$ACTION" == "up" ]]; then
  if [[ "$STATEFUL_NODES" == "cluster" ]]; then
    try "docker stack deploy -c $COMPOSE_FILE_PATH/docker-compose.cluster.yml instant" "Failed to deploy cluster"
  else
    try "docker stack deploy -c $COMPOSE_FILE_PATH/docker-compose.yml $elastic_search_dev_compose_param instant" "Failed to deploy Analytics Datastore Elastic Search"
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
