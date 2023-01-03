#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare POSTGRES_SERVICES=()
declare SERVICE_NAMES=()

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  POSTGRES_SERVICES=(
    "santempi-psql-1"
  )
  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    POSTGRES_SERVICES=(
      "${POSTGRES_SERVICES[@]}"
      "santempi-psql-2"
      "santempi-psql-3"
    )
  fi

  SERVICE_NAMES=(
    "${POSTGRES_SERVICES[@]}"
    "santedb-www"
    "santedb-mpi"
  )

  readonly ACTION
  readonly MODE
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
  local sante_mpi_dev_compose_filename=""

  if [[ "$MODE" == "dev" ]]; then
    package::log info "Running package in DEV mode"
    postgres_dev_compose_filename="docker-compose-postgres.dev.yml"
    sante_mpi_dev_compose_filename="docker-compose.dev.yml"
  else
    package::log info "Running package in PROD mode"
  fi

  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    postgres_cluster_compose_filename="docker-compose-postgres.cluster.yml"
  fi

  (
    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose-postgres.yml" "$postgres_cluster_compose_filename" "$postgres_dev_compose_filename"
    docker::deploy_sanity "${POSTGRES_SERVICES[@]}"

    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.yml" "$sante_mpi_dev_compose_filename"
    docker::deploy_sanity "santedb-mpi" "santedb-www"
  ) ||
    {
      package::log error "Failed to deploy package"
      exit 1
    }
}

function destroy_package() {
  for service_name in "${SERVICE_NAMES[@]}"; do
    docker::service_destroy "$service_name"
  done

  docker::try_remove_volume santedb-data santempi-psql-1-data

  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    log warn "Volumes are only deleted on the host on which the command is run. Postgres volumes on other nodes are not deleted"
  fi
}

main() {
  init_vars "$@"
  import_sources

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    if [[ "${CLUSTERED_MODE}" == "true" ]]; then
      package::log info "Running package in Cluster node mode"
    else
      package::log info "Running package in Single node mode"
    fi

    initialize_package
  elif [[ "${ACTION}" == "down" ]]; then
    package::log info "Scaling down package"

    docker::scale_services_down "${SERVICE_NAMES[@]}"
  elif [[ "${ACTION}" == "destroy" ]]; then
    package::log info "Destroying package"
    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
