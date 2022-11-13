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
    log info "Running Identity Access Manager Keycloak package in DEV mode"
    keycloak_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
  else
    log info "Running Identity Access Manager Keycloak package in PROD mode"
    keycloak_dev_compose_param=""
  fi

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml $keycloak_dev_compose_param instant" "Failed to deploy Identity Access Manager Keycloak"

    docker::await_container_startup identity-access-manager-keycloak
    docker::await_container_status identity-access-manager-keycloak Running

    config::await_network_join "instant_identity-access-manager-keycloak"

    log info "Setting config digests"
    config::set_config_digests "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml
    #try "docker stack deploy -c ${COMPOSE_FILE_PATH}/importer/docker-compose.config.yml instant" "Failed to start config importer"

    #log info "Waiting to give config importer time to run before cleaning up service"

    #config::remove_config_importer keycloak-config-importer

    # Ensure config importer is removed
    #config::await_service_removed instant_keycloak-config-importer

    #log info "Removing stale configs..."
    #config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml "keycloak"

    docker::deploy_sanity identity-access-manager-keycloak
  elif [[ "${ACTION}" == "down" ]]; then
    try "docker service scale instant_identity-access-manager-keycloak=0" "Failed to scale down identity-access-manager-keycloak"
  elif [[ "${ACTION}" == "destroy" ]]; then
    docker::service_destroy identity-access-manager-keycloak
    #docker::service_destroy keycloak-config-importer
    #docker::try_remove_volume keycloak-data

    #docker::prune_configs "keycloak"
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
