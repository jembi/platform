#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare STACK="elasticsearch"

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
    "docker stack deploy -c $COMPOSE_FILE_PATH/docker-compose.certs.yml $STACK" \
    throw \
    "Creating certificates failed"

  docker::await_container_startup $STACK create_certs
  docker::await_service_status $STACK create_certs Complete

  log info "Creating cert helper..."
  try \
    "docker run --rm --network host --name es-cert-helper -w /temp \
    -v ${STACK}_certgen:/temp-certificates \
    -v instant:/temp busybox sh \
    -c \"mkdir -p /temp/certs; cp -r /temp-certificates/* /temp/certs\"" \
    throw \
    "Error creating es-cert-helper"

  docker::service_destroy $STACK create_certs
  docker::await_container_destroy $STACK create_certs
  docker::await_container_destroy $STACK es-cert-helper
  try "docker volume rm ${STACK}_certgen" catch "Failed to remove volume ${STACK}_certgen"
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
      ${STACK}_analytics-datastore-elastic-search-$n" \
      throw \
      "Error updating analytics-datastore-elastic-search-$n"
    overwrite "Updating analytics-datastore-elastic-search-$n with certs... Done"
  done
}

function initialize_package() {
  local elastic_search_dev_compose_filename=""
  local container_status=""
  local compose_files=()

  if [[ "$MODE" == "dev" ]]; then
    log info "Running package in DEV mode"
    elastic_search_dev_compose_filename="docker-compose.dev.yml"
  else
    log info "Running package in PROD mode"
  fi

  (
    if [[ "$CLUSTERED_MODE" == "true" ]]; then
      create_certs
      docker::deploy_service $STACK "${COMPOSE_FILE_PATH}" "docker-compose.cluster.yml" "defer-sanity"
      add_docker_configs
      container_status="Running"
      compose_files=("$COMPOSE_FILE_PATH/docker-compose.cluster.yml")
    else
      docker::deploy_service $STACK "${COMPOSE_FILE_PATH}" "docker-compose.yml" "defer-sanity" "$elastic_search_dev_compose_filename"
      container_status="Starting"
      compose_files=("$COMPOSE_FILE_PATH/docker-compose.yml" "$COMPOSE_FILE_PATH/$elastic_search_dev_compose_filename")
    fi

    log info "Waiting for elasticsearch to start before automatically setting built-in passwords"

    docker::await_service_status $STACK "$ES_LEADER_NODE" "$container_status"
    install_expect
    set_elasticsearch_passwords "$ES_LEADER_NODE"

    docker::deploy_sanity $STACK $compose_files
  ) || {
    log error "Failed to deploy package"
    exit 1
  }

  docker::deploy_config_importer $STACK "$COMPOSE_FILE_PATH/importer/docker-compose.config.yml" "elastic-search-config-importer" "elasticsearch"
}

function destroy_package() {
  docker::stack_destroy "$STACK"

  if [[ "$CLUSTERED_MODE" == "true" ]]; then
    log warn "Volumes are only deleted on the host on which the command is run. Cluster volumes on other nodes are not deleted"
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

    docker::scale_services $STACK 1
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down package"

    docker::scale_services $STACK 0
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying package"

    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
