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
  if [[ "$MODE" == "dev" ]]; then
    log info "Running Client Registry JeMPI package in DEV mode"
    kafdrop_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.kafdrop-dev.yml"
    dgraph_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dgraph-dev.yml"
  else
    log info "Running Client Registry JeMPI package in PROD mode"
    kafdrop_dev_compose_param=""
    dgraph_dev_compose_param=""
  fi

  if [[ "$STATEFUL_NODES" == "cluster" ]]; then
    log info "Running in clustered mode"
    dgraph_cluster_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dgraph-cluster.yml"
  else
    log info "Running in single-node mode"
    dgraph_cluster_compose_param=""
  fi

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.kafka.yml instant" "Failed to deploy Client Registry - JeMPI"

    docker::await_service_ready jempi-kafka-01
    docker::await_service_ready jempi-kafka-02
    docker::await_service_ready jempi-kafka-03

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.kafdrop.yml $kafdrop_dev_compose_param instant" "Failed to deploy jempi-Kafdrop"

    docker::await_service_ready jempi-kafdrop

    config::set_config_digests "${COMPOSE_FILE_PATH}"/importer/docker-compose.config.yml

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/importer/docker-compose.config.yml instant" "Failed to deploy jempi-kafka-config-importer"

    log info "Waiting to give JeMPI Kafka config importer time to run before cleaning up service"

    config::remove_config_importer jempi-kafka-config-importer
    config::await_service_removed instant_jempi-kafka-config-importer

    config::remove_stale_service_configs "${COMPOSE_FILE_PATH}"/importer/docker-compose.config.yml "jempi-kafka"

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.dgraph.yml $dgraph_dev_compose_param $dgraph_cluster_compose_param instant" "Failed to deploy Client Registry - JeMPI"

    docker::await_service_ready jempi-zero-01

    docker::await_service_ready jempi-alpha-01
    docker::await_service_ready jempi-alpha-02
    docker::await_service_ready jempi-alpha-03

    docker::await_service_ready jempi-ratel

    docker::deploy_sanity "jempi-kafka-01" "jempi-kafka-02" "jempi-kafka-03" "jempi-kafdrop" "jempi-zero-01" "jempi-alpha-01" "jempi-alpha-02" "jempi-alpha-03" "jempi-ratel"
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down client-registry-jempi"

    try "docker service scale instant_jempi-kafka-01=0" "Failed to scale down jempi-kafka-01"
    try "docker service scale instant_jempi-kafka-02=0" "Failed to scale down jempi-kafka-02"
    try "docker service scale instant_jempi-kafka-03=0" "Failed to scale down jempi-kafka-03"

    try "docker service scale instant_jempi-kafdrop=0" "Failed to scale down jempi-kafdrop"

    try "docker service scale instant_jempi-zero-01=0" "Failed to scale down jempi-zero-01"

    try "docker service scale instant_jempi-alpha-01=0" "Failed to scale down jempi-alpha-01"
    try "docker service scale instant_jempi-alpha-02=0" "Failed to scale down jempi-alpha-02"
    try "docker service scale instant_jempi-alpha-03=0" "Failed to scale down jempi-alpha-03"

    try "docker service scale instant_jempi-ratel=0" "Failed to scale down jempi-ratel"
  elif [[ "${ACTION}" == "destroy" ]]; then
    log warn "Volumes are only deleted on the host on which the command is run. Volumes on other nodes are not deleted"

    docker::service_destroy jempi-kafka-01
    docker::service_destroy jempi-kafka-02
    docker::service_destroy jempi-kafka-03

    docker::service_destroy jempi-kafdrop

    docker::service_destroy jempi-kafka-config-importer

    docker::service_destroy jempi-zero-01

    docker::service_destroy jempi-alpha-01
    docker::service_destroy jempi-alpha-02
    docker::service_destroy jempi-alpha-03

    docker::service_destroy jempi-ratel

    docker::try_remove_volume jempi-kafka-01-data
    docker::try_remove_volume jempi-kafka-02-data
    docker::try_remove_volume jempi-kafka-03-data

    docker::try_remove_volume jempi-zero-01-data

    docker::try_remove_volume jempi-alpha-01-data
    docker::try_remove_volume jempi-alpha-02-data
    docker::try_remove_volume jempi-alpha-03-data

    docker::prune_configs "jempi-kafka"
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
