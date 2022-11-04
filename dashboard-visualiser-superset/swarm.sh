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

main() {

  if [[ "${MODE}" == "dev" ]]; then
    log info "Running Dashboard Visualiser Superset package in DEV mode"
    superset_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
  else
    log info "Running Dashboard Visualiser Superset package in PROD mode"
    superset_dev_compose_param=""
  fi

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    config::set_config_digests "$COMPOSE_FILE_PATH"/docker-compose.yml
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml $superset_dev_compose_param instant" "Failed to deploy Dashboard Visualiser Superset"

    docker::await_container_startup dashboard-visualiser-superset
    docker::await_container_status dashboard-visualiser-superset Running

    config::await_network_join "instant_dashboard-visualiser-superset"

    log info "Setting config digests"
    config::set_config_digests "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/importer/docker-compose.config.yml instant" "Failed to start config importer"

    log info "Waiting to give core config importer time to run before cleaning up service"

    config::remove_config_importer superset-config-importer

    # Ensure config importer is removed
    config::await_service_removed instant_superset-config-importer

    log info "Removing stale configs..."
    config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml "superset"
    config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/docker-compose.yml "superset"

    docker::deploy_sanity dashboard-visualiser-superset
  elif [[ "${ACTION}" == "down" ]]; then
    try "docker service scale instant_dashboard-visualiser-superset=0" "Failed to scale down dashboard-visualiser-superset"
  elif [[ "${ACTION}" == "destroy" ]]; then
    docker::service_destroy dashboard-visualiser-superset
    docker::service_destroy superset-config-importer

    # Removing Superset volumes
    docker::try_remove_volume superset
    docker::try_remove_volume superset-frontend
    docker::try_remove_volume superset_home

    docker::prune_configs "superset"
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
