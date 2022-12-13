#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare ROOT_PATH=""
declare service_name=""

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  ROOT_PATH="${COMPOSE_FILE_PATH}/.."

  service_name="data-mapper-logstash"

  if [[ "${NODE_MODE}" == "cluster" ]]; then
    export LOGSTASH_YML_CONFIG="logstash-logstash.cluster.yml"
  else
    export LOGSTASH_YML_CONFIG="logstash-logstash.yml"
  fi

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly ROOT_PATH
  readonly service_name
}

# shellcheck disable=SC1091
function import_sources() {
  source "${ROOT_PATH}/utils/docker-utils.sh"
  source "${ROOT_PATH}/utils/config-utils.sh"
  source "${ROOT_PATH}/utils/log.sh"
}

dev_mount_logstash() {
  if [[ "$LOGSTASH_DEV_MOUNT" == "true" ]]; then
    if [[ -z $LOGSTASH_PACKAGE_PATH ]]; then
      log error "LOGSTASH_PACKAGE_PATH environment variable not specified. Please specify LOGSTASH_PACKAGE_PATH as stated in the README."
      exit 1
    fi

    logstash_dev_mount_compose_param="/docker-compose.dev-mnt.yml"
  fi
}

inject_pipeline_elastic_hosts() {
  ES_HOSTS=${ES_HOSTS:-"\"analytics-datastore-elastic-search:9200\""}
  for file in "${COMPOSE_FILE_PATH}"/pipeline/*.conf; do
    sed -i "s/\$ES_HOSTS/${ES_HOSTS}/g" "${file}"
  done
}

function initialize_package() {
  local logstash_dev_compose_param=""
  local logstash_dev_mount_compose_param=""

  if [[ "$MODE" == "dev" ]]; then
    log info "Running Data Mapper Logstash package in DEV mode"
    logstash_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
  else
    log info "Running Data Mapper Logstash package in PROD mode"
  fi

  config::generate_service_configs data-mapper-logstash /usr/share/logstash "${COMPOSE_FILE_PATH}/pipeline" "${COMPOSE_FILE_PATH}" "logstash"
  logstash_temp_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.tmp.yml"

  (
    dev_mount_logstash

    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.yml" "$logstash_dev_compose_param" "$logstash_dev_mount_compose_param" "$logstash_temp_compose_param"
    docker::deploy_sanity "${service_name}"
  ) || {
    log error "Failed to deploy Data Mapper Logstash package"
    exit 1
  }

  inject_pipeline_elastic_hosts

  config::remove_stale_service_configs "${COMPOSE_FILE_PATH}/docker-compose.yml" "logstash"
}

function scale_services_down() {
  try \
    "docker service scale instant_$service_name=0" \
    catch \
    "Failed to scale down $service_name"
}

function destroy_package() {
  docker::service_destroy clickhouse-config-importer

  docker::service_destroy "$service_name"

  docker::try_remove_volume logstash-data

  docker::prune_configs "logstash"
}

main() {
  init_vars "$@"
  import_sources

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    log info "Running Data Mapper Logstash package in ${NODE_MODE} node mode"

    initialize_package
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down Data Mapper Logstash"

    scale_services_down
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying Data Mapper Logstash"

    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
