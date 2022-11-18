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
  log info "Waiting for Postgres to start up before HAPI-FHIR"

  docker::await_container_startup postgres-1
  docker::await_container_status postgres-1 Running

  if [[ "$STATEFUL_NODES" == "cluster" ]]; then
    docker::await_container_startup postgres-2
    docker::await_container_status postgres-2 Running

    docker::await_container_startup postgres-3
    docker::await_container_status postgres-3 Running
  fi
}

if [ "${STATEFUL_NODES}" == "cluster" ]; then
  log info "Running FHIR Datastore HAPI FHIR package in Cluster node mode"
  postgres_cluster_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose-postgres.cluster.yml"
else
  log info "Running FHIR Datastore HAPI FHIR package in Single node mode"
  postgres_cluster_compose_param=""
fi

if [ "${MODE}" == "dev" ]; then
  log info "Running FHIR Datastore HAPI FHIR package in DEV mode"
  postgres_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose-postgres.dev.yml"
  hapi_fhir_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  log info "Running FHIR Datastore HAPI FHIR package in PROD mode"
  postgres_dev_compose_param=""
  hapi_fhir_dev_compose_param=""
fi

if [ "${ACTION}" == "init" ]; then
  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose-postgres.yml $postgres_cluster_compose_param $postgres_dev_compose_param instant" "Failed to deploy FHIR Datastore HAPI FHIR Postgres"

  await_postgres_start

  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml $hapi_fhir_dev_compose_param instant" "Failed to deploy FHIR Datastore HAPI FHIR"

  if [ "$STATEFUL_NODES" == "cluster" ]; then
    docker::deploy_sanity hapi-fhir postgres-1 postgres-2 postgres-3
  else
    docker::deploy_sanity hapi-fhir postgres-1
  fi
elif [ "${ACTION}" == "up" ]; then
  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose-postgres.yml $postgres_cluster_compose_param $postgres_dev_compose_param instant" "Failed to stand up hapi-fhir postgres"

  await_postgres_start

  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml $hapi_fhir_dev_compose_param instant" "Failed to stand up hapi-fhir"
elif [ "${ACTION}" == "down" ]; then
  try "docker service scale instant_hapi-fhir=0 instant_postgres-1=0" "Failed to scale down hapi-fhir"

  if [ "$STATEFUL_NODES" == "cluster" ]; then
    try "docker service scale instant_postgres-2=0 instant_postgres-3=0" "Failed to scale down hapi-fhir postgres replicas"
  fi

elif [ "${ACTION}" == "destroy" ]; then
  docker::service_destroy hapi-fhir
  docker::service_destroy postgres-1
  docker::try_remove_volume hapi-postgres-1-data

  if [ "${STATEFUL_NODES}" == "cluster" ]; then
    docker::service_destroy postgres-2
    docker::service_destroy postgres-3
    docker::try_remove_volume hapi-postgres-2-data
    docker::try_remove_volume hapi-postgres-3-data
    log warn "Volumes are only deleted on the host on which the command is run. Postgres volumes on other nodes are not deleted"
  fi

  docker::prune_configs "hapi-fhir"
else
  log error "Valid options are: init, up, down, or destroy"
fi
