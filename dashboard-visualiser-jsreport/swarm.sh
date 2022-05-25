#!/bin/bash

readonly ACTION=$1
readonly MODE=$2

TIMESTAMP="$(date "+%Y%m%d%H%M%S")"
readonly TIMESTAMP

STATEFUL_NODES=${STATEFUL_NODES:-"cluster"}

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)

ROOT_PATH="${COMPOSE_FILE_PATH}/.."
. "${ROOT_PATH}/utils/config-utils.sh"

if [[ "$MODE" == "dev" ]]; then
  echo "Running JS Reports package in DEV mode"
  js_report_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  echo "Running JS Reports package in PROD mode"
  js_report_dev_compose_param=""
fi

configure_nginx() {
  if [[ "${INSECURE}" == "true" ]]; then
    docker config create --label name=nginx "${TIMESTAMP}-http-jsreport-insecure.conf" "${COMPOSE_FILE_PATH}/config/http-jsreport-insecure.conf"
    echo "Updating nginx service: adding jsreport config file..."
    if ! docker service update \
      --config-add source="${TIMESTAMP}-http-jsreport-insecure.conf",target=/etc/nginx/conf.d/http-jsreport-insecure.conf \
      instant_reverse-proxy-nginx >/dev/null; then
      echo "Error updating nginx service"
      exit 1
    fi
    echo "Done updating nginx service"
  else
    docker config create --label name=nginx "${TIMESTAMP}-http-jsreport-secure.conf" "${COMPOSE_FILE_PATH}/config/http-jsreport-secure.conf"
    echo "Updating nginx service: adding jsreport config file..."
    if ! docker service update \
      --config-add source="${TIMESTAMP}-http-jsreport-secure.conf",target=/etc/nginx/conf.d/http-jsreport-secure.conf \
      instant_reverse-proxy-nginx >/dev/null; then
      echo "Error updating nginx service"
      exit 1
    fi
    echo "Done updating nginx service"
  fi
}

if [[ "${JS_REPORT_DEV_MOUNT}" == "true" ]] && [[ "${ACTION}" == "init" ]]; then
  if [[ -z "${JS_REPORT_PACKAGE_PATH}" ]]; then
    echo "ERROR: JS_REPORT_PACKAGE_PATH environment variable not specified. Please specify JS_REPORT_PACKAGE_PATH as stated in the README."
    exit 1
  fi
  echo "MAKE SURE YOU HAVE RUN 'set-permissions.sh' SCRIPT BEFORE AND AFTER RUNNING JS REPORT"

  echo "Attaching dev mount..."
  js_report_dev_mount_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev-mnt.yml"
fi

main() {
  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $js_report_dev_compose_param $js_report_dev_mount_compose_param instant

    if [[ "${JS_REPORT_DEV_MOUNT}" != "true" ]]; then
      echo "Verifying JS Reports service status"
      config::await_service_running "dashboard-visualiser-jsreport" "$COMPOSE_FILE_PATH"/docker-compose.await-helper.yml "$JS_REPORT_INSTANCES"

      config::set_config_digests "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml
      docker stack deploy -c "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml instant

      config::remove_config_importer "jsreport-config-importer"
      config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml "jsreport" &>/dev/null
    fi

    if [[ "${MODE}" != "dev" ]]; then
      configure_nginx "$@"
    fi
  elif [[ "${ACTION}" == "down" ]]; then
    docker service scale instant_dashboard-visualiser-jsreport=0
  elif [[ "${ACTION}" == "destroy" ]]; then
    docker service rm instant_dashboard-visualiser-jsreport instant_jsreport-config-importer instant_await-helper &>/dev/null
  else
    echo "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
