#!/bin/bash

# Constants
readonly ACTION=$1
readonly MODE=$2
readonly STATEFUL_NODES=${STATEFUL_NODES:-"cluster"}

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)
readonly COMPOSE_FILE_PATH

# Import libraries
ROOT_PATH="${COMPOSE_FILE_PATH}/.."
. "${ROOT_PATH}/utils/config-utils.sh"
. "${ROOT_PATH}/utils/docker-utils.sh"

AwaitPostgresToStart() {
  echo "Await Postgres to start up before HAPI-FHIR"

  docker::await_container_startup postgres-1
  docker::await_container_status postgres-1 running
  
  if [ "$STATEFUL_NODES" == "cluster" ]; then
    docker::await_container_startup postgres-2
    docker::await_container_status postgres-2 running

    docker::await_container_startup postgres-3
    docker::await_container_status postgres-3 running
  fi
}

if [ "$STATEFUL_NODES" == "cluster" ]; then
  echo "Running FHIR Datastore HAPI FHIR package in Cluster node mode"
  postgresClusterComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose-postgres.cluster.yml"
else
  echo "Running FHIR Datastore HAPI FHIR package in Single node mode"
  postgresClusterComposeParam=""
fi

if [ "$MODE" == "dev" ]; then
  echo "Running FHIR Datastore HAPI FHIR package in DEV mode"
  postgresDevComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose-postgres.dev.yml"
  hapiFhirDevComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  echo "Running FHIR Datastore HAPI FHIR package in PROD mode"
  postgresDevComposeParam=""
  hapiFhirDevComposeParam=""
fi

if [ "$ACTION" == "init" ]; then
  docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose-postgres.yml $postgresClusterComposeParam $postgresDevComposeParam instant
  
  AwaitPostgresToStart

  docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $hapiFhirDevComposeParam instant
elif [ "$ACTION" == "up" ]; then
  docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose-postgres.yml $postgresClusterComposeParam $postgresDevComposeParam instant
  
  AwaitPostgresToStart
  
  docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $hapiFhirDevComposeParam instant
elif [ "$ACTION" == "down" ]; then
  docker service scale instant_hapi-fhir=0 instant_postgres-1=0

  if [ "$STATEFUL_NODES" == "cluster" ]; then
    docker service scale instant_postgres-2=0 instant_postgres-3=0
  fi

elif [ "$ACTION" == "destroy" ]; then
  docker service rm instant_hapi-fhir instant_postgres-1 &>/dev/null

  config::await_service_removed instant_hapi-fhir
  config::await_service_removed instant_postgres-1

  docker volume rm instant_hapi-postgres-1-data &>/dev/null

  if [ "$STATEFUL_NODES" == "cluster" ]; then
    docker service rm instant_postgres-2 instant_postgres-3 &>/dev/null
    config::await_service_removed instant_postgres-2
    config::await_service_removed instant_postgres-3
    docker volume rm instant_hapi-postgres-2-data instant_hapi-postgres-3-data &>/dev/null

    echo "Volumes are only deleted on the host on which the command is run. Postgres volumes on other nodes are not deleted"
  fi
else
  echo "Valid options are: init, up, down, or destroy"
fi
