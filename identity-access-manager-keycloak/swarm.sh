#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare STACK="keycloak"

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
}

# shellcheck disable=SC1091
function import_sources() {
  source "${UTILS_PATH}/docker-utils.sh"
  source "${UTILS_PATH}/config-utils.sh"
  source "${UTILS_PATH}/log.sh"
}

function append_client_config() {
  local -r CONFIG_NAME="${1:?$(missing_param "append_client_config" "CONFIG_NAME")}"
  local -r CLIENT_ID_ENV_NAME="${2:?$(missing_param "append_client_config" "CLIENT_ID_ENV_NAME")}"
  local -r CLIENT_ROLES_ENV_NAME="${3:?$(missing_param "append_client_config" "CLIENT_ROLES_ENV_NAME")}"

  # Comma separate env var and quote the values
  IFS=',' read -r -a client_roles_array <<<"$CLIENT_ROLES_ENV_NAME"
  client_roles_quoted=$(jq --compact-output --null-input '$ARGS.positional' --args -- "${client_roles_array[@]}")
  # Append clients configs
  yq ".clients += [load(\"${COMPOSE_FILE_PATH}/config/$CONFIG_NAME.json\")]" "${COMPOSE_FILE_PATH}/config/realm.json" >tmp.json
  # Append clients roles
  jq ".users[0].clientRoles += {\"$CLIENT_ID_ENV_NAME\": ${client_roles_quoted[*]}}" tmp.json >"${COMPOSE_FILE_PATH}/config/realm.json"
  rm -f tmp.json
}

function append_config_sso_enabled() {
  if [[ "${KC_GRAFANA_SSO_ENABLED}" == "true" ]]; then
    append_client_config "grafana" "$KC_GRAFANA_CLIENT_ID" "$KC_GRAFANA_CLIENT_ROLES"
  fi
  if [[ "${KC_SUPERSET_SSO_ENABLED}" == "true" ]]; then
    append_client_config "superset" "$KC_SUPERSET_CLIENT_ID" "$KC_SUPERSET_CLIENT_ROLES"
  fi
  if [[ "${KC_JEMPI_SSO_ENABLED}" == "true" ]]; then
    append_client_config "jempi" "$KC_JEMPI_CLIENT_ID" "$KC_JEMPI_CLIENT_ROLES"
  fi
  if [[ "${KC_OPENHIM_SSO_ENABLED}" == "true" ]]; then
    append_client_config "openhim" "$KC_OPENHIM_CLIENT_ID" "$KC_OPENHIM_CLIENT_ROLES"
  fi
}

function initialize_package() {
  local postgres_cluster_compose_filename=""
  local postgres_dev_compose_filename=""
  local keycloak_dev_compose_filename=""

  if [ "${MODE}" == "dev" ]; then
    log info "Running package in DEV mode"
    postgres_dev_compose_filename="docker-compose-postgres.dev.yml"
    keycloak_dev_compose_filename="docker-compose.dev.yml"
  else
    log info "Running package in PROD mode"
  fi

  if [ "${CLUSTERED_MODE}" == "true" ]; then
    postgres_cluster_compose_filename="docker-compose-postgres.cluster.yml"
  fi

  append_config_sso_enabled

  (
    docker::deploy_service $STACK "${COMPOSE_FILE_PATH}" "docker-compose-postgres.yml" "$postgres_cluster_compose_filename" "$postgres_dev_compose_filename"
    docker::deploy_service $STACK "${COMPOSE_FILE_PATH}" "docker-compose.yml" "$keycloak_dev_compose_filename"
  ) ||
    {
      log error "Failed to deploy package"
      exit 1
    }
}

function destroy_package() {
  docker::stack_destroy $STACK

  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    log warn "Volumes are only deleted on the host on which the command is run. Postgres volumes on other nodes are not deleted"
  fi

  docker::prune_configs "keycloak"
}

main() {
  init_vars "$@"
  import_sources

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    if [[ "${CLUSTERED_MODE}" == "true" ]]; then
      log info "Running package in Cluster node mode"
    else
      log info "Running package in Single node mode"
    fi

    initialize_package
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down package"

    docker::scale_services $STACK 0
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying package"
    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
