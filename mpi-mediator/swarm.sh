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

main() {
  if [[ "${STATEFUL_NODES}" == "cluster" ]]; then
    log info "Running MPI-Mediator package in Cluster node mode"
    local mpi_mediator_cluster_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.cluster.yml"
  else
    log info "Running MPI-Mediator package in Single node mode"
    local mpi_mediator_cluster_compose_param=""
  fi

  if [[ "${MODE}" == "dev" ]]; then
    log info "Running MPI-Mediator package in DEV mode"
    local mpi_mediator_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
  else
    log info "Running MPI-Mediator package in PROD mode"
    local mpi_mediator_dev_compose_param=""
  fi

  if [[ "$ACTION" == "init" ]]; then
    log info "Deploying MPI-Mediator..."
    try "docker stack deploy -c $COMPOSE_FILE_PATH/docker-compose.yml $mpi_mediator_cluster_compose_param $mpi_mediator_dev_compose_param instant" "Failed to deploy mpi-mediator"
    overwrite "Deploying MPI-Mediator... Done"
  elif [[ "$ACTION" == "up" ]]; then
    log info "Updating MPI-Mediator..."
    try "docker stack deploy -c $COMPOSE_FILE_PATH/docker-compose.yml $mpi_mediator_cluster_compose_param $mpi_mediator_dev_compose_param instant" "Failed to stand up mpi-mediator"
    overwrite "Updating MPI-Mediator... Done"
  elif [[ "$ACTION" == "down" ]]; then
    log info "Scaling MPI-Mediator down..."
    try "docker service scale instant_mpi-mediator=0" "Failed to scale down mpi-mediator"
    overwrite "Scaling MPI-Mediator down... Done"
  elif [[ "$ACTION" == "destroy" ]]; then
    log info "Destroying MPI-Mediator..."
    docker::service_destroy mpi-mediator
    overwrite "Destroying MPI-Mediator... Done"
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
