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

  create-clickhouse-volumes-with-node-index() {

  for node in "$@"; do
    docker create --name clickhouse_helper-"${node}" -v clickhouse-configs-"${node}":/etc/clickhouse-server/config.d busybox
    docker cp "${COMPOSE_FILE_PATH}"/configs/gen/analytics-datastore-clickhouse-"${node}" clickhouse_helper-"${node}":/etc/clickhouse-server/config.d/
    docker rm clickhouse_helper-"${node}"
  done
}

main() {

  if [[ "${STATEFUL_NODES}" == "cluster" ]]; then
    log info "Running Clickhouse package in Cluster node mode"
    create-clickhouse-volumes-with-node-index "01" "02" "03"
    clickhouse_cluster_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose-clickhouse.cluster.yml"
  else
    log info "Running Clickhouse package in Single node mode"
    clickhouse_cluster_compose_param=""
  fi
  if [[ "${MODE}" == "dev" ]]; then
    log info "Running Analytics Datastore Clickhouse package in DEV mode"
    clickhouse_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
  else
    log info "Running Analytics Datastore Clickhouse package in PROD mode"
    clickhouse_dev_compose_param=""
  fi

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml $clickhouse_cluster_compose_param $clickhouse_dev_compose_param instant" "Failed to deploy Analytics Datastore Clickhouse"

    docker::await_container_startup analytics-datastore-clickhouse-01
    docker::await_container_status analytics-datastore-clickhouse-01 Running

    config::await_network_join "instant_analytics-datastore-clickhouse"

    log info "Setting config digests"
    config::set_config_digests "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/importer/docker-compose.config.yml instant" "Failed to start config importer"

    log info "Waiting to give core config importer time to run before cleaning up service"
    
    config::remove_config_importer clickhouse-config-importer

    # Ensure config importer is removed
    config::await_service_removed instant_clickhouse-config-importer

    log info "Removing stale configs..."
    config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml "clickhouse"
  elif [[ "${ACTION}" == "down" ]]; then
    try "docker service scale instant_analytics-datastore-clickhouse=0" "Failed to scale down analytics-datastore-clickhouse"
  elif [[ "${ACTION}" == "destroy" ]]; then
    docker::service_destroy analytics-datastore-clickhouse-01
    docker::service_destroy clickhouse-config-importer
    docker::try_remove_volume clickhouse-data-01

    docker::prune_configs "clickhouse"
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
