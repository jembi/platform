#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare service_name=""

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  service_name="data-mapper-logstash"

  if [[ "${NODE_MODE}" == "cluster" ]]; then
    export LOGSTASH_YML_CONFIG="logstash-logstash.cluster.yml"
  else
    export LOGSTASH_YML_CONFIG="logstash-logstash.yml"
  fi

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly service_name
}

# shellcheck disable=SC1091
function import_sources() {
  source "${UTILS_PATH}/docker-utils.sh"
  source "${UTILS_PATH}/config-utils.sh"
  source "${UTILS_PATH}/log.sh"
}

dev_mount_logstash() {
  if [[ "$LOGSTASH_DEV_MOUNT" == "true" ]]; then
    if [[ -z $LOGSTASH_PACKAGE_PATH ]]; then
      log error "LOGSTASH_PACKAGE_PATH environment variable not specified. Please specify LOGSTASH_PACKAGE_PATH as stated in the README."
      exit 1
    fi

    log info "Attaching dev mount file"
    logstash_dev_mount_compose_filename="docker-compose.dev-mnt.yml"
  fi
}

inject_pipeline_elastic_hosts() {
  ES_HOSTS=${ES_HOSTS:-"\"analytics-datastore-elastic-search:9200\""}
  for file in "${COMPOSE_FILE_PATH}"/pipeline/*.conf; do
    sed -i "s/\$ES_HOSTS/${ES_HOSTS}/g" "${file}"
  done
}

function initialize_package() {
  local logstash_dev_compose_filename=""
  local logstash_dev_mount_compose_filename=""
  local logstash_temp_compose_filename=""

  if [[ "$MODE" == "dev" ]]; then
    log info "Running Data Mapper Logstash package in DEV mode"
    logstash_dev_compose_filename="docker-compose.dev.yml"
  else
    log info "Running Data Mapper Logstash package in PROD mode"
  fi

  if [[ "$LOGSTASH_DEV_MOUNT" == "true" ]]; then
    log warn "LOGSTASH_DEV_MOUNT is enabled: Please make sure TO REPLACE ES_HOSTS MANUALLY IN ALL THE FILES inside pipeline folder!"
  else
    inject_pipeline_elastic_hosts

    config::generate_service_configs data-mapper-logstash /usr/share/logstash "${COMPOSE_FILE_PATH}/pipeline" "${COMPOSE_FILE_PATH}" "logstash"
    logstash_temp_compose_filename="docker-compose.tmp.yml"
  fi

  (
    dev_mount_logstash

    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.yml" "$logstash_dev_compose_filename" "$logstash_dev_mount_compose_filename" "$logstash_temp_compose_filename"
    docker::deploy_sanity "${service_name}"
  ) || {
    log error "Failed to deploy Data Mapper Logstash package"
    exit 1
  }
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
