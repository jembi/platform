#!/bin/bash

# Constants
readonly ACTION=$1
readonly MODE=$2
COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)

# Import libraries
ROOT_PATH="${COMPOSE_FILE_PATH}/.."
. "${ROOT_PATH}/utils/docker-utils.sh"
. "${ROOT_PATH}/utils/log.sh"

readonly GF_SECURITY_ADMIN_USER=${GF_SECURITY_ADMIN_USER:-"admin"}
readonly GF_SECURITY_ADMIN_PASSWORD=${GF_SECURITY_ADMIN_PASSWORD:-"dev_password_only"}

if [[ "${MODE}" == "dev" ]]; then
  log info "Running Message Bus Kafka package in DEV mode"
  monitoring_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  log info "Running Message Bus Kafka package in PROD mode"
  monitoring_dev_compose_param=""
fi

if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
  try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml ${monitoring_dev_compose_param} instant" "Failed to deploy monitoring stack"
elif [[ "${ACTION}" == "down" ]]; then
  try "docker service scale instant_grafana=0 instant_prometheus=0 instant_prometheus-kafka-adapter=0" "Failed to down monitoring stack"
  try "docker service rm instant_cadvisor" "Failed to remove global service cadvisor"
  docker::await_service_destroy "cadvisor"
  try "docker service rm instant_node-exporter" "Failed to remove global service node-exporter"
  docker::await_service_destroy "node-exporter"
elif [[ "${ACTION}" == "destroy" ]]; then
  docker::service_destroy grafana
  docker::service_destroy prometheus
  docker::service_destroy prometheus-kafka-adapter

  try "docker service rm instant_cadvisor" "Failed to remove global service cadvisor"
  docker::await_service_destroy "cadvisor"
  try "docker service rm instant_node-exporter" "Failed to remove global service node-exporter"
  docker::await_service_destroy "node-exporter"

  docker::try_remove_volume prometheus_data
  docker::try_remove_volume grafana_data

  if [[ $STATEFUL_NODES == "cluster" ]]; then
    log warn "Volumes are only deleted on the host on which the command is run. Monitoring volumes on other nodes are not deleted"
  fi
else
  log error "Valid options are: init, up, down, or destroy"
fi
