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

await_postgres_start() {
  log info "Waiting for Postgres to start up before KeyCloak"

  docker::await_container_startup keycloak-postgres-1
  docker::await_container_status keycloak-postgres-1 Running

  if [[ "$STATEFUL_NODES" == "cluster" ]]; then
    docker::await_container_startup keycloak-postgres-2
    docker::await_container_status keycloak-postgres-2 Running

    docker::await_container_startup keycloak-postgres-3
    docker::await_container_status keycloak-postgres-3 Running
  fi
}

main() {
  if [ "${STATEFUL_NODES}" == "cluster" ]; then
    log info "Running Identity Access Manager Keycloak package in Cluster node mode"
    postgres_cluster_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose-postgres.cluster.yml"
  else
    log info "Running Identity Access Manager Keycloak package in Single node mode"
    postgres_cluster_compose_param=""
  fi

  if [[ "${MODE}" == "dev" ]]; then
    log info "Running Identity Access Manager Keycloak package in DEV mode"
    keycloak_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
    postgres_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose-postgres.dev.yml"
  else
    log info "Running Identity Access Manager Keycloak package in PROD mode"
    keycloak_dev_compose_param=""
    postgres_dev_compose_param=""
  fi

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    log info "Setting config digests"
    config::set_config_digests "$COMPOSE_FILE_PATH"/docker-compose.yml

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose-postgres.yml $postgres_cluster_compose_param $postgres_dev_compose_param instant" "Failed to deploy KeyCloak Postgres"

    await_postgres_start

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml $keycloak_dev_compose_param instant" "Failed to deploy Identity Access Manager Keycloak"

    docker::await_container_startup identity-access-manager-keycloak
    docker::await_container_status identity-access-manager-keycloak Running

    config::await_network_join "instant_identity-access-manager-keycloak"

    if [ "$STATEFUL_NODES" == "cluster" ]; then
      docker::deploy_sanity identity-access-manager-keycloak keycloak-postgres-1 keycloak-postgres-2 keycloak-postgres-3
    else
      docker::deploy_sanity identity-access-manager-keycloak keycloak-postgres-1
    fi
  elif [[ "${ACTION}" == "down" ]]; then
    try "docker service scale instant_identity-access-manager-keycloak=0 instant_keycloak-postgres-1=0" "Failed to scale down identity-access-manager-keycloak"

    if [ "$STATEFUL_NODES" == "cluster" ]; then
      try "docker service scale instant_keycloak-postgres-2=0 instant_keycloak-postgres-3=0" "Failed to scale down keycloak postgres replicas"
    fi
  elif [[ "${ACTION}" == "destroy" ]]; then
    docker::service_destroy identity-access-manager-keycloak

    docker::service_destroy keycloak-postgres-1
    docker::try_remove_volume keycloak-postgres-1-data

    if [ "${STATEFUL_NODES}" == "cluster" ]; then
      docker::service_destroy keycloak-postgres-2
      docker::service_destroy keycloak-postgres-3
      docker::try_remove_volume keycloak-postgres-2-data
      docker::try_remove_volume keycloak-postgres-3-data
      log warn "Volumes are only deleted on the host on which the command is run. Postgres volumes on other nodes are not deleted"
    fi

    docker::prune_configs "keycloak"
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
