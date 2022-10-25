#!/bin/bash

# Constants
readonly ACTION=$1
readonly MODE=$2

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

await_postgres_start() {
  log info "Waiting for Postgres to start up before SanteMPI"

  docker::await_container_startup santempi-psql-1
  docker::await_container_status santempi-psql-1 Running

  if [[ "$STATEFUL_NODES" == "cluster" ]]; then
    docker::await_container_startup santempi-psql-2
    docker::await_container_status santempi-psql-2 Running

    docker::await_container_startup santempi-psql-3
    docker::await_container_status santempi-psql-3 Running
  fi
}

main() {
  if [ "${STATEFUL_NODES}" == "cluster" ]; then
    log info "Running Client Registry SanteMPI package in Cluster node mode"
    local postgres_cluster_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose-postgres.cluster.yml"
  else
    log info "Running Client Registry SanteMPI package in Single node mode"
    local postgres_cluster_compose_param=""
  fi

  if [ "$MODE" == "dev" ]; then
    log info "Running Client Registry SanteMPI package in DEV mode"
    local postgres_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose-postgres.dev.yml"
    local sante_mpi_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
  else
    log info "Running Client Registry SanteMPI package in PROD mode"
    local postgres_dev_compose_param=""
    local sante_mpi_dev_compose_param=""
  fi

  if [ "$ACTION" == "init" ]; then
    try "docker stack deploy -c $COMPOSE_FILE_PATH/docker-compose-postgres.yml $postgres_cluster_compose_param $postgres_dev_compose_param instant" "Failed to deploy SanteMPI Postgres"

    await_postgres_start

    try "docker stack deploy -c ""$COMPOSE_FILE_PATH""/docker-compose.yml $sante_mpi_dev_compose_param instant" "Failed to deploy SanteMPI"
  elif [ "$ACTION" == "up" ]; then
    try "docker stack deploy -c $COMPOSE_FILE_PATH/docker-compose-postgres.yml $postgres_cluster_compose_param $postgres_dev_compose_param instant" "Failed to stand up SanteMPI Postgres"

    await_postgres_start

    try "docker stack deploy -c ""$COMPOSE_FILE_PATH""/docker-compose.yml $sante_mpi_dev_compose_param instant" "Failed to stand up SanteMPI"
  elif [ "$ACTION" == "down" ]; then
    try "docker service scale instant_santedb-mpi=0 instant_santedb-www=0 instant_santempi-psql-1=0" "Failed to scale down santeMPI"

    if [ "$STATEFUL_NODES" == "cluster" ]; then
      try "docker service scale instant_santempi-psql-2=0 instant_santempi-psql-3=0" "Failed to scale down santeMPI postgres replicas"
    fi

  elif [ "$ACTION" == "destroy" ]; then
    docker::service_destroy santedb-www
    docker::service_destroy santedb-mpi
    docker::service_destroy santempi-psql-1
    docker::try_remove_volume santedb-data
    docker::try_remove_volume santempi-psql-1-data

    if [ "${STATEFUL_NODES}" == "cluster" ]; then
      docker::service_destroy santempi-psql-2
      docker::service_destroy santempi-psql-3
      docker::try_remove_volume santempi-psql-2-data
      docker::try_remove_volume santempi-psql-3-data
      log warn "Volumes are only deleted on the host on which the command is run. Postgres volumes on other nodes are not deleted"
    fi
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
