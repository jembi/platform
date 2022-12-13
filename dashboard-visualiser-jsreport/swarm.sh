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

  service_name="dashboard-visualiser-jsreport"

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly ROOT_PATH
  readonly service_name
}

# shellcheck disable=SC1091
function import_sources() {
  source "${ROOT_PATH}/utils/docker-utils.sh"
  source "${ROOT_PATH}/utils/log.sh"
}

unbound_ES_HOSTS_check() {
  if [[ ${NODE_MODE} == "cluster" ]] && [[ -z ${ES_HOSTS:-""} ]]; then
    log error "ES_HOSTS environment variable not set... Exiting"
    exit 1
  fi
}

dev_mount_jsreport() {
  if [[ "${JS_REPORT_DEV_MOUNT}" == "true" ]] && [[ "${ACTION}" == "init" ]]; then
    if [[ -z "${JS_REPORT_PACKAGE_PATH}" ]]; then
      log error "ERROR: JS_REPORT_PACKAGE_PATH environment variable not specified. Please specify JS_REPORT_PACKAGE_PATH as stated in the README."
      # exit 1
    fi
    log warn "MAKE SURE YOU HAVE RUN 'set-permissions.sh' SCRIPT BEFORE AND AFTER RUNNING JS REPORT"

    log info "Attaching dev mount..."
    js_report_dev_mount_compose_param="docker-compose.dev-mnt.yml"
  fi
}

function initialize_package() {
  local js_report_dev_compose_param=""
  local js_report_dev_mount_compose_param=""

  if [[ "${MODE}" == "dev" ]]; then
    log info "Running Jsreport package in DEV mode"
    js_report_dev_compose_param="docker-compose.dev.yml"
  else
    log info "Running Jsreport package in in PROD mode"
  fi

  (
    dev_mount_jsreport

    unbound_ES_HOSTS_check

    docker::deploy_service "${COMPOSE_FILE_PATH}" "docker-compose.yml" "$js_report_dev_compose_param" "$js_report_dev_mount_compose_param"
    docker::deploy_sanity "${service_name}"
  ) || {
    log error "Failed to deploy Jsreport package"
    exit 1
  }

  if [[ "${JS_REPORT_DEV_MOUNT}" != "true" ]]; then
    log info "Verifying JS Report service status"
    config::await_service_running "dashboard-visualiser-jsreport" "${COMPOSE_FILE_PATH}"/docker-compose.await-helper.yml "${JS_REPORT_INSTANCES}"

    docker::deploy_config_importer "$COMPOSE_FILE_PATH/importer/docker-compose.config.yml" "jsreport-config-importer" "jsreport"
  fi
}

function scale_services_down() {
  try \
    "docker service scale instant_$service_name=0" \
    catch \
    "Failed to scale down $service_name"
}

function destroy_package() {
  docker::service_destroy jsreport-config-importer
  docker::service_destroy await-helper

  docker::service_destroy "$service_name"

  docker::prune_configs "jsreport"
}

main() {
  init_vars "$@"
  import_sources

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    log info "Running Analytics Datastore Clickhouse package in ${NODE_MODE} node mode"

    initialize_package
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down Analytics Datastore Clickhouse"

    scale_services_down
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying Analytics Datastore Clickhouse"

    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
