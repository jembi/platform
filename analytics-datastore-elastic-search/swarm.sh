#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare ROOT_PATH=""
declare container_status=""
declare service_names=()

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  ROOT_PATH="${COMPOSE_FILE_PATH}/.."

  if [[ "${NODE_MODE}" == "cluster" ]]; then
    container_status="Running"
    service_names=(
      "analytics-datastore-elastic-search-01"
      "analytics-datastore-elastic-search-02"
      "analytics-datastore-elastic-search-03"
    )
  else
    container_status="Starting"
    service_names=(
      "analytics-datastore-elastic-search"
    )
  fi

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly ROOT_PATH
  readonly container_status
  readonly service_names
}

# shellcheck disable=SC1091
function import_sources() {
  source "${ROOT_PATH}/utils/docker-utils.sh"
  source "${ROOT_PATH}/utils/config-utils.sh"
  source "${ROOT_PATH}/utils/log.sh"
}

function install_expect() {
  log info "Installing Expect..."
  try "apt-get install -y expect &>/dev/null" throw "Fatal: Failed to install Expect library. Cannot update Elasticsearch passwords"
  overwrite "Installing Expect... Done"
}

function set_elasticsearch_passwords() {
  local container=$1
  log info "Setting passwords..."
  local elastic_search_container_id=""
  elastic_search_container_id=$(docker ps -qlf name="${container}")
  try \
    "${COMPOSE_FILE_PATH}/set-elastic-passwords.exp ${elastic_search_container_id}" \
    throw \
    "Fatal: Failed to set elastic passwords. Cannot update Elastic Search passwords"
  overwrite "Setting passwords... Done"
}

function create_certs() {
  log info "Creating certificates..."
  try \
    "docker stack deploy -c $COMPOSE_FILE_PATH/docker-compose.certs.yml instant" \
    throw \
    "Creating certificates failed"

  docker::await_container_startup create_certs
  docker::await_container_status create_certs Complete

  log info "Creating cert helper..."
  try \
    "docker run --rm --network host --name es-cert-helper -w /temp \
    -v instant_certgen:/temp-certificates \
    -v instant:/temp busybox sh \
    -c \"mkdir -p /temp/certs; cp -r /temp-certificates/* /temp/certs\"" \
    throw \
    "Error creating es-cert-helper"

  docker::service_destroy create_certs
  docker::await_container_destroy create_certs
  docker::await_container_destroy es-cert-helper
  docker::try_remove_volume certgen
}

function add_docker_configs() {
  local -r TIMESTAMP="$(date "+%Y%m%d%H%M%S")"
  log info "Creating configs..."

  try "docker config create --label name=elasticsearch ${TIMESTAMP}-ca.crt ./certs/ca/ca.crt" catch "Error creating config ca.crt"

  number_configs=(
    "01"
    "02"
    "03"
  )
  for n in "${number_configs[@]}"; do
    try "docker config create --label name=elasticsearch ${TIMESTAMP}-es$n.crt ./certs/es$n/es$n.crt" catch "Error creating config es$n.crt"
    try "docker config create --label name=elasticsearch ${TIMESTAMP}-es$n.key ./certs/es$n/es$n.key" catch "Error creating config es$n.key"

    log info "Updating analytics-datastore-elastic-search-$n with certs..."
    try \
      "docker service update \
      --config-add source=${TIMESTAMP}-ca.crt,target=/usr/share/elasticsearch/config/certs/ca/ca.crt \
      --config-add source=${TIMESTAMP}-es$n.crt,target=/usr/share/elasticsearch/config/certs/es$n/es$n.crt \
      --config-add source=${TIMESTAMP}-es$n.key,target=/usr/share/elasticsearch/config/certs/es$n/es$n.key \
      --replicas 1 \
      instant_analytics-datastore-elastic-search-$n" \
      catch \
      "Error updating analytics-datastore-elastic-search-$n"
    overwrite "Updating analytics-datastore-elastic-search-$n with certs... Done"
  done
}

function initialize_package() {
  local elastic_search_dev_compose_param=""

  if [[ "$MODE" == "dev" ]]; then
    log info "Running Analytics Datastore Elastic Search package in DEV mode"
    elastic_search_dev_compose_param="docker-compose.dev.yml"
  else
    log info "Running Analytics Datastore Elastic Search package in PROD mode"
  fi

  (
    if [[ "$NODE_MODE" == "cluster" ]]; then
      create_certs
      docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.cluster.yml"
      add_docker_configs
    else
      docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.yml" "$elastic_search_dev_compose_param"
    fi

    log info "Waiting for elasticsearch to start before automatically setting built-in passwords"

    docker::await_container_status "$ES_LEADER_NODE" "$container_status"
    install_expect
    set_elasticsearch_passwords "$ES_LEADER_NODE"

    docker::deploy_sanity "${service_names[@]}"

  ) || {
    log error "Failed to deploy Analytics Datastore Elastic Search package"
    exit 1
  }

  config::await_network_join "instant_$ES_LEADER_NODE"

  docker::deploy_config_importer "$COMPOSE_FILE_PATH/importer/docker-compose.config.yml" "elastic-search-config-importer" "elasticsearch"
}

function scale_services() {
  local -r REPLICA_NUMBER=${1:?"FATAL: scale_services REPLICA_NUMBER not provided"}
  local scale_action="up"

  if [[ $REPLICA_NUMBER == 0 ]]; then
    scale_action="down"
  fi

  for service_name in "${service_names[@]}"; do
    try \
      "docker service scale instant_$service_name=$REPLICA_NUMBER" \
      catch \
      "Failed to scale $scale_action $service_name"
  done
}

function destroy_package() {
  docker::service_destroy elastic-search-config-importer

  for service_name in "${service_names[@]}"; do
    docker::service_destroy "$service_name"
  done

  if [[ "$NODE_MODE" == "cluster" ]]; then
    docker::try_remove_volume es01-data certs
    log warn "Volumes are only deleted on the host on which the command is run. Cluster volumes on other nodes are not deleted"
  else
    docker::try_remove_volume es-data
  fi

  docker::prune_configs "elasticsearch"
}

main() {
  init_vars "$@"
  import_sources

  if [[ "${ACTION}" == "init" ]]; then
    log info "Running Analytics Datastore Elastic Search package in ${NODE_MODE} node mode"

    initialize_package
  elif [[ "$ACTION" == "up" ]]; then
    log info "Scaling up Analytics Datastore Elastic Search"

    scale_services 1
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down Analytics Datastore Elastic Search"

    scale_services 0
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying Analytics Datastore Elastic Search"

    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
