#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare CONTAINER_STATUS=""
declare SERVICE_NAMES=()

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    CONTAINER_STATUS="Running"

    for i in {1..3}; do
      SERVICE_NAMES=(
        "${SERVICE_NAMES[@]}"
        "analytics-datastore-elastic-search-0$i"
      )
    done
  else
    CONTAINER_STATUS="Starting"
    SERVICE_NAMES=(
      "analytics-datastore-elastic-search"
    )
  fi

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly CONTAINER_STATUS
  readonly SERVICE_NAMES
}

# shellcheck disable=SC1091
function import_sources() {
  source "${UTILS_PATH}/docker-utils.sh"
  source "${UTILS_PATH}/config-utils.sh"
  source "${UTILS_PATH}/log.sh"
}

function install_expect() {
  log info "Installing Expect..."
  try "apt-get install -y expect &>/dev/null" throw "Fatal: Failed to install Expect library. Cannot update Elasticsearch passwords"
  overwrite "Installing Expect... Done"
}

function set_elasticsearch_passwords() {
  local container=$1

  local elastic_search_container_id=""
  elastic_search_container_id=$(docker ps -qlf name="${container}")

  log info "Setting passwords..."
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
  docker::await_service_status create_certs Complete

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
  local -r path_config_certs="/usr/share/elasticsearch/config/certs/"

  log info "Creating configs..."

  try "docker config create --label name=elasticsearch ${TIMESTAMP}-ca.crt ./certs/ca/ca.crt" throw "Error creating config ca.crt"

  number_configs=(
    "01"
    "02"
    "03"
  )
  for n in "${number_configs[@]}"; do
    try "docker config create --label name=elasticsearch ${TIMESTAMP}-es$n.crt ./certs/es$n/es$n.crt" throw "Error creating config es$n.crt"
    try "docker config create --label name=elasticsearch ${TIMESTAMP}-es$n.key ./certs/es$n/es$n.key" throw "Error creating config es$n.key"

    log info "Updating analytics-datastore-elastic-search-$n with certs..."
    try \
      "docker service update \
      --config-add source=${TIMESTAMP}-ca.crt,target=$path_config_certs/ca/ca.crt \
      --config-add source=${TIMESTAMP}-es$n.crt,target=$path_config_certs/es$n/es$n.crt \
      --config-add source=${TIMESTAMP}-es$n.key,target=$path_config_certs/es$n/es$n.key \
      --replicas 1 \
      instant_analytics-datastore-elastic-search-$n" \
      throw \
      "Error updating analytics-datastore-elastic-search-$n"
    overwrite "Updating analytics-datastore-elastic-search-$n with certs... Done"
  done
}

function initialize_package() {
  local elastic_search_dev_compose_filename=""

  if [[ "$MODE" == "dev" ]]; then
    log info "Running package in DEV mode"
    elastic_search_dev_compose_filename="docker-compose.dev.yml"
  else
    log info "Running package in PROD mode"
  fi

  (
    if [[ "$CLUSTERED_MODE" == "true" ]]; then
      create_certs
      docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.cluster.yml"
      add_docker_configs
    else
      docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.yml" "$elastic_search_dev_compose_filename"
    fi

    log info "Waiting for elasticsearch to start before automatically setting built-in passwords"

    docker::await_service_status "$ES_LEADER_NODE" "$CONTAINER_STATUS"
    install_expect
    set_elasticsearch_passwords "$ES_LEADER_NODE"

    docker::deploy_sanity "${SERVICE_NAMES[@]}"

  ) || {
    log error "Failed to deploy package"
    exit 1
  }

  config::await_network_join "instant_$ES_LEADER_NODE"

  docker::deploy_config_importer "$COMPOSE_FILE_PATH/importer/docker-compose.config.yml" "elastic-search-config-importer" "elasticsearch"
}

function destroy_package() {
  docker::service_destroy "${SERVICE_NAMES[@]}" "elastic-search-config-importer"

  if [[ "$CLUSTERED_MODE" == "true" ]]; then
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
    if [[ "${CLUSTERED_MODE}" == "true" ]]; then
      log info "Running package in Cluster mode"
    else
      log info "Running package in Single mode"
    fi

    initialize_package
  elif [[ "$ACTION" == "up" ]]; then
    log info "Scaling up package"

    docker::scale_services_up 1 "${SERVICE_NAMES[@]}"
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down package"

    docker::scale_services_down "${SERVICE_NAMES[@]}"
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying package"

    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
