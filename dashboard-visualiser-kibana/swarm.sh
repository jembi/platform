#!/bin/bash

readonly ACTION=$1
readonly MODE=$2
readonly KIBANA_INSTANCES=${KIBANA_INSTANCES:-1}

readonly STATEFUL_NODES=${STATEFUL_NODES:-"cluster"}

TIMESTAMP="$(date "+%Y%m%d%H%M%S")"
readonly TIMESTAMP

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)
readonly COMPOSE_FILE_PATH

ROOT_PATH="${COMPOSE_FILE_PATH}/.."
readonly ROOT_PATH

. "${ROOT_PATH}/utils/config-utils.sh"
. "${ROOT_PATH}/utils/docker-utils.sh"
. "${ROOT_PATH}/utils/log.sh"

configure_nginx() {

  if [[ "${INSECURE}" == "true" ]]; then
    try "docker config create --label name=nginx ${TIMESTAMP}-http-kibana-insecure.conf ${COMPOSE_FILE_PATH}/config/http-kibana-insecure.conf" "Error creating insecure kibana nginx conf"
    log info "Updating nginx service: adding kibana config file..."
    try "docker service update --config-add source=${TIMESTAMP}-http-kibana-insecure.conf,target=/etc/nginx/conf.d/http-kibana-insecure.conf instant_reverse-proxy-nginx" "Error updating nginx service"
    overwrite "Updating nginx service: adding kibana config file... Done"
  else
    try "docker config create --label name=nginx ${TIMESTAMP}-http-kibana-secure.conf ${COMPOSE_FILE_PATH}/config/http-kibana-secure.conf" "Error creating secure kibana nginx conf"
    log info "Updating nginx service: adding kibana config file..."
    try "docker service update --config-add source=${TIMESTAMP}-http-kibana-secure.conf,target=/etc/nginx/conf.d/http-kibana-secure.conf instant_reverse-proxy-nginx" "Error updating nginx service"
    overwrite "Updating nginx service: adding kibana config file... Done"
  fi
}

import_kibana_dashboards() {
  log info "Setting config digests"
  config::set_config_digests "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml
  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/importer/docker-compose.config.yml instant" "Failed to start config importer"
  config::remove_config_importer "kibana-config-importer"
  config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml "kibana"
}

main() {
  if [[ "${MODE}" == "dev" ]]; then
    log info "Running Dashboard Visualiser Kibana package in DEV mode"
    kibana_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
  else
    log info "Running Dashboard Visualiser Kibana package in PROD mode"
    kibana_dev_compose_param=""
  fi

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then

    if [[ "${STATEFUL_NODES}" == "cluster" ]]; then
      export KIBANA_YML_CONFIG="kibana-kibana-cluster.yml"
    else
      export KIBANA_YML_CONFIG="kibana-kibana.yml"
    fi

    config::set_config_digests "${COMPOSE_FILE_PATH}"/docker-compose.yml
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml $kibana_dev_compose_param instant" "Failed to deploy Dashboard Visualiser Kibana"

    docker::await_container_startup dashboard-visualiser-kibana
    docker::await_container_status dashboard-visualiser-kibana running

    config::await_network_join "instant_dashboard-visualiser-kibana"

    log info "Setting config digests"
    config::set_config_digests "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/importer/docker-compose.config.yml instant" "Failed to start config importer"

    import_kibana_dashboards

    if [[ "${MODE}" != "dev" ]]; then
      configure_nginx "$@"
    fi

  elif [[ "${ACTION}" == "down" ]]; then
    try "docker service scale instant_dashboard-visualiser-kibana=0" "Failed to scale down dashboard-visualiser-kibana"
  elif [[ "${ACTION}" == "destroy" ]]; then
    try "docker service rm instant_dashboard-visualiser-kibana instant_await-helper instant_kibana-config-importer" "Failed to destroy dashboard-visualiser-kibana"
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
