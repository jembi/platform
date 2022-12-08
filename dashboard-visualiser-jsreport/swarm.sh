#!/bin/bash

readonly ACTION=$1
readonly MODE=$2

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)

ROOT_PATH="${COMPOSE_FILE_PATH}/.."
. "${ROOT_PATH}/utils/config-utils.sh"
. "${ROOT_PATH}/utils/docker-utils.sh"
. "${ROOT_PATH}/utils/log.sh"

unbound_ES_HOSTS_check() {
  if [[ ${STATEFUL_NODES} == "cluster" ]] && [[ -z ${ES_HOSTS:-""} ]]; then
    log error "ES_HOSTS environment variable not set... Exiting"
    exit 1
  fi
}

main() {
  if [[ "$MODE" == "dev" ]]; then
    log info "Running JS Report package in DEV mode"
    js_report_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
  else
    log info "Running JS Report package in PROD mode"
    js_report_dev_compose_param=""
  fi

  local js_report_dev_mount_compose_param=""
  if [[ "${JS_REPORT_DEV_MOUNT}" == "true" ]] && [[ "${ACTION}" == "init" ]]; then
    if [[ -z "${JS_REPORT_PACKAGE_PATH}" ]]; then
      log error "ERROR: JS_REPORT_PACKAGE_PATH environment variable not specified. Please specify JS_REPORT_PACKAGE_PATH as stated in the README."
      exit 1
    fi
    log warn "MAKE SURE YOU HAVE RUN 'set-permissions.sh' SCRIPT BEFORE AND AFTER RUNNING JS REPORT"

    log info "Attaching dev mount..."
    js_report_dev_mount_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev-mnt.yml"
  fi

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    unbound_ES_HOSTS_check

    try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml $js_report_dev_compose_param $js_report_dev_mount_compose_param instant" "Failed to deploy JS Report"

    if [[ "${JS_REPORT_DEV_MOUNT}" != "true" ]]; then
      log info "Verifying JS Report service status"
      config::await_service_running "dashboard-visualiser-jsreport" "${COMPOSE_FILE_PATH}"/docker-compose.await-helper.yml "${JS_REPORT_INSTANCES}"

      config::set_config_digests "${COMPOSE_FILE_PATH}"/importer/docker-compose.config.yml
      try "docker stack deploy -c ${COMPOSE_FILE_PATH}/importer/docker-compose.config.yml instant" "Failed to start config importer"

      config::remove_config_importer "jsreport-config-importer"
      config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml "jsreport"
    fi

    docker::deploy_sanity dashboard-visualiser-jsreport
  elif [[ "${ACTION}" == "down" ]]; then
    try "docker service scale instant_dashboard-visualiser-jsreport=0" "Failed to scale down dashboard-visualiser-jsreport"
  elif [[ "${ACTION}" == "destroy" ]]; then
    docker::service_destroy dashboard-visualiser-jsreport
    docker::service_destroy jsreport-config-importer
    docker::service_destroy await-helper

    docker::prune_configs "jsreport"
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
