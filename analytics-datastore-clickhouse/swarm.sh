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
  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    if [[ "${STATEFUL_NODES}" == "cluster" ]]; then
      log info "Running Analytics Datastore Clickhouse package in Cluster node mode"
      clickhouse_cluster_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.cluster.yml"

      log info "Setting config digests"
      config::set_config_digests "${COMPOSE_FILE_PATH}/docker-compose.cluster.yml"

    else
      log info "Running Analytics Datastore Clickhouse package in Single node mode"
      clickhouse_cluster_compose_param=""
    fi
    if [[ "${MODE}" == "dev" ]]; then
      log info "Running Analytics Datastore Clickhouse package in DEV mode"
      clickhouse_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
    else
      log info "Running Analytics Datastore Clickhouse package in PROD mode"
      clickhouse_dev_compose_param=""
    fi
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml $clickhouse_cluster_compose_param $clickhouse_dev_compose_param instant" "Failed to deploy Analytics Datastore Clickhouse"

    docker::await_container_startup analytics-datastore-clickhouse-01
    docker::await_container_status analytics-datastore-clickhouse-01 Running

    if [[ "${STATEFUL_NODES}" == "cluster" ]]; then
      docker::await_container_startup analytics-datastore-clickhouse-02
      docker::await_container_status analytics-datastore-clickhouse-02 Running

      docker::await_container_startup analytics-datastore-clickhouse-03
      docker::await_container_status analytics-datastore-clickhouse-03 Running

      docker::await_container_startup analytics-datastore-clickhouse-04
      docker::await_container_status analytics-datastore-clickhouse-04 Running
    fi

    log info "Setting config digests"
    config::set_config_digests "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/importer/docker-compose.config.yml instant" "Failed to start config importer"

    log info "Waiting to give core config importer time to run before cleaning up service"

    config::remove_config_importer clickhouse-config-importer

    # Ensure config importer is removed
    config::await_service_removed instant_clickhouse-config-importer

    log info "Removing stale configs..."
    config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml "clickhouse"

    if [[ "${STATEFUL_NODES}" == "cluster" ]]; then
      docker::deploy_sanity analytics-datastore-clickhouse-01 analytics-datastore-clickhouse-02 analytics-datastore-clickhouse-03 analytics-datastore-clickhouse-04
    else
      docker::deploy_sanity analytics-datastore-clickhouse-01
    fi
  elif [[ "${ACTION}" == "down" ]]; then
    try "docker service scale instant_analytics-datastore-clickhouse-01=0" "Failed to scale down analytics-datastore-clickhouse-01"

    if [[ "${STATEFUL_NODES}" == "cluster" ]]; then
      try "docker service scale instant_analytics-datastore-clickhouse-02=0" "Failed to scale down analytics-datastore-clickhouse-02"
      try "docker service scale instant_analytics-datastore-clickhouse-03=0" "Failed to scale down analytics-datastore-clickhouse-03"
      try "docker service scale instant_analytics-datastore-clickhouse-04=0" "Failed to scale down analytics-datastore-clickhouse-04"
    fi
  elif [[ "${ACTION}" == "destroy" ]]; then
    docker::service_destroy analytics-datastore-clickhouse-01
    docker::service_destroy clickhouse-config-importer
    docker::try_remove_volume clickhouse-data-01

    if [[ "${STATEFUL_NODES}" == "cluster" ]]; then
      docker::service_destroy analytics-datastore-clickhouse-02
      docker::service_destroy analytics-datastore-clickhouse-03
      docker::service_destroy analytics-datastore-clickhouse-04
    fi

    docker::prune_configs "clickhouse"
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
