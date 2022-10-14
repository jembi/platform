#!/bin/bash

# Constants
readonly ACTION=$1

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)
readonly COMPOSE_FILE_PATH

# Import libraries
ROOT_PATH="${COMPOSE_FILE_PATH}/.."
. "${ROOT_PATH}/utils/config-utils.sh"
. "${ROOT_PATH}/utils/docker-utils.sh"
. "${ROOT_PATH}/utils/log.sh"


main() {
  echo "Removing stale configs..."
  config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml "santempi-kafka"

  if [ "${STATEFUL_NODES}" == "cluster" ]; then
    log info "Running Client Registry SanteMPI Helper package in Cluster node mode"
    local SANTEMPI_MEDIATORS_CLUSTER_COMPOSE_PARAM="-c ${COMPOSE_FILE_PATH}/docker-compose.cluster.yml"
  else
    log info "Running Client Registry SanteMPI Helper package in Single node mode"
    local SANTEMPI_MEDIATORS_CLUSTER_COMPOSE_PARAM=""
  fi

  if [ "$ACTION" == "init" ]; then
    log info "Setting config digests"
    config::set_config_digests "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml

    try "docker stack deploy -c $COMPOSE_FILE_PATH/docker-compose.yml $SANTEMPI_MEDIATORS_CLUSTER_COMPOSE_PARAM instant" "Failed to deploy SanteMPI mediators"

    log info "Creating Kafka topics used by the mediators"
    try "docker stack deploy -c $COMPOSE_FILE_PATH/importer/docker-compose.config.yml instant" "Failed to created Kafka topics used by the SanteMPI mediators"

    log info "Waiting to give core config importer time to run before cleaning up service"
    
    config::remove_config_importer santempi-kafka-config-importer

    # Ensure config importer is removed
    config::await_service_removed instant_santempi-kafka-config-importer
  elif [ "$ACTION" == "up" ]; then
     try "docker stack deploy -c $COMPOSE_FILE_PATH/docker-compose.yml $SANTEMPI_MEDIATORS_CLUSTER_COMPOSE_PARAM instant" "Failed to stand up SanteMPI mediators"
  elif [ "$ACTION" == "down" ]; then
    try "docker service scale instant_mpi-checker=0 instant_mpi-updater=0" "Failed to scale down santeMPI mediators"
  elif [ "$ACTION" == "destroy" ]; then
    docker::service_destroy mpi-checker
    docker::service_destroy mpi-updater

    docker::prune_configs "santempi-kafka"
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
