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

    docker::await_service_ready kafka-01
    docker::await_service_ready kafka-02
    docker::await_service_ready kafka-03

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.kafdrop.yml $kafdrop_dev_compose_param instant" "Failed to deploy jempi-Kafdrop"

    docker::await_service_ready jempi-kafdrop

    config::set_config_digests "${COMPOSE_FILE_PATH}"/importer/docker-compose.config.yml

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/importer/docker-compose.config.yml instant" "Failed to deploy jempi-kafka-config-importer"

    log info "Waiting to give JeMPI Kafka config importer time to run before cleaning up service"

    config::remove_config_importer jempi-kafka-config-importer
    config::await_service_removed instant_jempi-kafka-config-importer

    config::remove_stale_service_configs "${COMPOSE_FILE_PATH}"/importer/docker-compose.config.yml "jempi-kafka"

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.dgraph.yml $dgraph_dev_compose_param $dgraph_cluster_compose_param instant" "Failed to deploy Client Registry - JeMPI"

    docker::await_service_ready zero-01

    docker::await_service_ready alpha-01
    docker::await_service_ready alpha-02
    docker::await_service_ready alpha-03

    docker::await_service_ready ratel

    docker::deploy_sanity "kafka-01" "kafka-02" "kafka-03" "jempi-kafdrop" "zero-01" "alpha-01" "alpha-02" "alpha-03" "ratel"
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down client-registry-jempi"

    try "docker service scale instant_kafka-01=0" "Failed to scale down kafka-01"
    try "docker service scale instant_kafka-02=0" "Failed to scale down kafka-02"
    try "docker service scale instant_kafka-03=0" "Failed to scale down kafka-03"

    try "docker service scale instant_jempi-kafdrop=0" "Failed to scale down jempi-kafdrop"

    try "docker service scale instant_zero-01=0" "Failed to scale down zero-01"

    try "docker service scale instant_alpha-01=0" "Failed to scale down alpha-01"
    try "docker service scale instant_alpha-02=0" "Failed to scale down alpha-02"
    try "docker service scale instant_alpha-03=0" "Failed to scale down alpha-03"

    try "docker service scale instant_ratel=0" "Failed to scale down ratel"
  elif [[ "${ACTION}" == "destroy" ]]; then
    log warn "Volumes are only deleted on the host on which the command is run. Volumes on other nodes are not deleted"

    docker::service_destroy kafka-01
    docker::service_destroy kafka-02
    docker::service_destroy kafka-03

    docker::service_destroy jempi-kafdrop

    docker::service_destroy jempi-kafka-config-importer

    docker::service_destroy zero-01

    docker::service_destroy alpha-01
    docker::service_destroy alpha-02
    docker::service_destroy alpha-03

    docker::service_destroy ratel

    docker::try_remove_volume kafka-01-data
    docker::try_remove_volume kafka-02-data
    docker::try_remove_volume kafka-03-data

    docker::try_remove_volume zero-01-data

    docker::try_remove_volume alpha-01-data
    docker::try_remove_volume alpha-02-data
    docker::try_remove_volume alpha-03-data

    docker::prune_configs "jempi-kafka"
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
