#!/bin/bash

readonly ACTION=$1
readonly MODE=$2

TIMESTAMP="$(date "+%Y%m%d%H%M%S")"
readonly TIMESTAMP

STATEFUL_NODES=${STATEFUL_NODES:-"cluster"}

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)
readonly COMPOSE_FILE_PATH

# Import libraries
ROOT_PATH="${COMPOSE_FILE_PATH}/.."
. "${ROOT_PATH}/utils/config-utils.sh"

configure_nginx() {
  if [[ "${INSECURE}" == "true" ]]; then
    docker config create --label name=nginx "${TIMESTAMP}-http-client-registry-santempi-insecure.conf" "${COMPOSE_FILE_PATH}/config/http-client-registry-santempi-insecure.conf"
    echo "Updating nginx service: adding client-registry-santempi config file..."
    if ! docker service update \
      --config-add source="${TIMESTAMP}-http-client-registry-santempi-insecure.conf",target=/etc/nginx/conf.d/http-client-registry-santempi-insecure.conf \
      instant_reverse-proxy-nginx >/dev/null; then
      echo "Error updating nginx service"
      exit 1
    fi
    echo "Done updating nginx service"
  else
    docker config create --label name=nginx "${TIMESTAMP}-http-client-registry-santempi-secure.conf" "${COMPOSE_FILE_PATH}/config/http-client-registry-santempi-secure.conf"
    echo "Updating nginx service: adding client-registry-santempi config file..."
    if ! docker service update \
      --config-add source="${TIMESTAMP}-http-client-registry-santempi-secure.conf",target=/etc/nginx/conf.d/http-client-registry-santempi-secure.conf \
      instant_reverse-proxy-nginx >/dev/null; then
      echo "Error updating nginx service"
      exit 1
    fi
    echo "Done updating nginx service"
  fi
}

main() {
  if [ $STATEFUL_NODES == "cluster" ]; then
    printf "\nRunning Client Registry SanteMPI package in Cluster node mode\n"
    POSTGRES_CLUSTER_COMPOSE_PARAM="-c ${COMPOSE_FILE_PATH}/docker-compose-postgres.cluster.yml"
  else
    printf "\nRunning Client Registry SanteMPI package in Single node mode\n"
    POSTGRES_CLUSTER_COMPOSE_PARAM=""
  fi

  if [ "$MODE" == "dev" ]; then
    printf "\nRunning Client Registry SanteMPI package in DEV mode\n"
    POSTGRES_DEV_COMPOSE_PARAM="-c ${COMPOSE_FILE_PATH}/docker-compose-postgres.dev.yml"
    SANTE_MPI_DEV_COMPOSE_PARAM="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
  else
    printf "\nRunning Client Registry SanteMPI package in PROD mode\n"
    POSTGRES_DEV_COMPOSE_PARAM=""
    SANTE_MPI_DEV_COMPOSE_PARAM=""
  fi

  if [ "$ACTION" == "init" ]; then
    docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose-postgres.yml $POSTGRES_CLUSTER_COMPOSE_PARAM $POSTGRES_DEV_COMPOSE_PARAM instant

    echo "Sleep 30 seconds to give Postgres time to start up before Sante MPI"
    sleep 30
    #TODO: Replace this sleep with await helper

    docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $SANTE_MPI_DEV_COMPOSE_PARAM instant
    if [[ "$MODE" != "dev" ]]; then
      configure_nginx "$@"
    fi
  elif [ "$ACTION" == "up" ]; then
    docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose-postgres.yml $POSTGRES_CLUSTER_COMPOSE_PARAM $POSTGRES_DEV_COMPOSE_PARAM instant

    echo "Sleep 20 seconds to give Postgres time to start up before Sante MPI"
    sleep 20
    #TODO: Replace this sleep with await helper

    docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $SANTE_MPI_DEV_COMPOSE_PARAM instant
  elif [ "$1" == "down" ]; then
    docker service scale instant_santedb-mpi=0 instant_santempi-psql-1=0 instant_santempi-psql-2=0 instant_santempi-psql-3=0
  elif [ "$1" == "destroy" ]; then
    docker service rm instant_santedb-www instant_santedb-mpi instant_santempi-psql-1 instant_santempi-psql-2 instant_santempi-psql-3

    echo "Sleep 10 Seconds to allow services to shut down before deleting volumes"
    sleep 10
    #TODO: Replace this sleep with await helper

    docker volume rm instant_santempi-psql-1-data instant_santempi-psql-2-data instant_santempi-psql-3-data

    if [ $STATEFUL_NODES == "cluster" ]; then
      echo "Volumes are only deleted on the host on which the command is run. Postgres volumes on other nodes are not deleted"
    fi
  else
    echo "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
