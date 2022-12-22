#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare postgres_services=()
declare service_names=()

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  postgres_services=(
    "postgres-1"
  )
  if [[ "${NODE_MODE}" == "cluster" ]]; then
    postgres_services=(
      "${postgres_services[@]}"
      "postgres-2"
      "postgres-3"
    )
  fi

  service_names=(
    "${postgres_services[@]}"
    "hapi-fhir"
  )

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly postgres_services
  readonly service_names
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
    log info "Running FHIR Datastore HAPI FHIR package in DEV mode"
    postgres_dev_compose_filename="docker-compose-postgres.dev.yml"
    hapi_fhir_dev_compose_filename="docker-compose.dev.yml"
  else
    log info "Running FHIR Datastore HAPI FHIR package in PROD mode"
  fi

  if [ "${NODE_MODE}" == "cluster" ]; then
    postgres_cluster_compose_filename="docker-compose-postgres.cluster.yml"
  fi

  (
    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose-postgres.yml" "$postgres_cluster_compose_filename" "$postgres_dev_compose_filename"
    docker::deploy_sanity "${postgres_services[@]}"

    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.yml" "$hapi_fhir_dev_compose_filename"
    docker::deploy_sanity "hapi-fhir"
  ) ||
    {
      log error "Failed to deploy FHIR Datastore HAPI FHIR package"
      exit 1
    }
}

function scale_services_down() {
  for service_name in "${service_names[@]}"; do
    try \
      "docker service scale instant_$service_name=0" \
      catch \
      "Failed to scale down $service_name"
  done
}

function destroy_package() {
  for service_name in "${service_names[@]}"; do
    docker::service_destroy "$service_name"
  done

  docker::try_remove_volume hapi-postgres-1-data

  if [[ "${NODE_MODE}" == "cluster" ]]; then
    log warn "Volumes are only deleted on the host on which the command is run. Postgres volumes on other nodes are not deleted"
  fi

  docker::prune_configs "hapi-fhir"
}

main() {
  init_vars "$@"
  import_sources

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    log info "Running FHIR Datastore HAPI FHIR package in ${NODE_MODE} node mode"

    initialize_package
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down FHIR Datastore HAPI FHIR"

    scale_services_down
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying FHIR Datastore HAPI FHIR"

    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
