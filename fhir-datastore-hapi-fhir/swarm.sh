#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare PACKAGE_NAME=""
declare UTILS_PATH=""
declare POSTGRES_SERVICES=()
declare SERVICE_NAMES=()

function init_vars() {
  ACTION=$1
  MODE=$2

  PACKAGE_NAME=$(basename "$PWD" | sed -e 's/-/ /g' -e 's/\b\(.\)/\u\1/g')

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  POSTGRES_SERVICES=(
    "postgres-1"
  )
  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    POSTGRES_SERVICES=(
      "${POSTGRES_SERVICES[@]}"
      "postgres-2"
      "postgres-3"
    )
  fi

  SERVICE_NAMES=(
    "${POSTGRES_SERVICES[@]}"
    "hapi-fhir"
  )

  readonly ACTION
  readonly MODE
  readonly PACKAGE_NAME
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly POSTGRES_SERVICES
  readonly SERVICE_NAMES
}

# shellcheck disable=SC1091
function import_sources() {
  source "${UTILS_PATH}/docker-utils.sh"
  source "${UTILS_PATH}/config-utils.sh"
  source "${UTILS_PATH}/log.sh"
}

function initialize_package() {
  local postgres_cluster_compose_filename=""
  local postgres_dev_compose_filename=""
  local hapi_fhir_dev_compose_filename=""

  if [ "${MODE}" == "dev" ]; then
    log info "Running $PACKAGE_NAME package in DEV mode"
    postgres_dev_compose_filename="docker-compose-postgres.dev.yml"
    hapi_fhir_dev_compose_filename="docker-compose.dev.yml"
  else
    log info "Running $PACKAGE_NAME package in PROD mode"
  fi

  if [ "${CLUSTERED_MODE}" == "true" ]; then
    postgres_cluster_compose_filename="docker-compose-postgres.cluster.yml"
  fi

  (
    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose-postgres.yml" "$postgres_cluster_compose_filename" "$postgres_dev_compose_filename"
    docker::deploy_sanity "${POSTGRES_SERVICES[@]}"

    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.yml" "$hapi_fhir_dev_compose_filename"
    docker::deploy_sanity "hapi-fhir"
  ) ||
    {
      log error "Failed to deploy $PACKAGE_NAME package"
      exit 1
    }
}

function destroy_package() {
  docker::service_destroy "${SERVICE_NAMES[@]}"

  docker::try_remove_volume hapi-postgres-1-data

  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    log warn "Volumes are only deleted on the host on which the command is run. Postgres volumes on other nodes are not deleted"
  fi

  docker::prune_configs "hapi-fhir"
}

main() {
  init_vars "$@"
  import_sources

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    if [[ "${CLUSTERED_MODE}" == "true" ]]; then
      log info "Running $PACKAGE_NAME package in Cluster node mode"
    else
      log info "Running $PACKAGE_NAME package in Single node mode"
    fi

    initialize_package
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down $PACKAGE_NAME"

    docker::scale_services_down "${SERVICE_NAMES[@]}"
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying $PACKAGE_NAME"

    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
