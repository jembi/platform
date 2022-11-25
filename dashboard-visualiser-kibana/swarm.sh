#!/bin/bash

readonly ACTION=$1
readonly MODE=$2

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

import_kibana_dashboards() {
  log info "Importing Kibana dashboard"
  config::set_config_digests "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml
  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/importer/docker-compose.config.yml --with-registry-auth instant" "Failed to start config importer"
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
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml $kibana_dev_compose_param --with-registry-auth instant" "Failed to deploy Dashboard Visualiser Kibana"

    docker::await_container_startup dashboard-visualiser-kibana
    docker::await_container_status dashboard-visualiser-kibana Running

    config::await_network_join "instant_dashboard-visualiser-kibana"

    log info "Setting config digests"
    config::set_config_digests "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/importer/docker-compose.config.yml --with-registry-auth instant" "Failed to start config importer"

    import_kibana_dashboards

    docker::deploy_sanity dashboard-visualiser-kibana
  elif [[ "${ACTION}" == "down" ]]; then
    try "docker service scale instant_dashboard-visualiser-kibana=0" "Failed to scale down dashboard-visualiser-kibana"
  elif [[ "${ACTION}" == "destroy" ]]; then
    docker::service_destroy dashboard-visualiser-kibana
    docker::service_destroy await-helper
    docker::service_destroy kibana-config-importer

    docker::prune_configs "kibana"
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
