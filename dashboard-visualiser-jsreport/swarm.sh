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
  JsReportDevComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  echo "Running JS Reports package in PROD mode"
  JsReportDevComposeParam=""
fi

await_jsr_running() {
  local startTime=$(date +%s)
  until [[ $(docker service ls -f name=instant_dashboard-visualiser-jsreport --format "{{.Replicas}}") == *"${JS_REPORT_INSTANCES}/${JS_REPORT_INSTANCES}"* ]]; do
    config::timeout_check $startTime "dashboard-visualiser-jsreport to start"
    sleep 1
  done

  local awaitHelperState=$(docker service ps instant_await-helper --format "{{.CurrentState}}")
  until [[ $awaitHelperState == *"Complete"* ]]; do
    config::timeout_check $startTime "dashboard-visualiser-jsreport status check"
    sleep 1

    awaitHelperState=$(docker service ps instant_await-helper --format "{{.CurrentState}}")
    if [[ $awaitHelperState == *"Failed"* ]] || [[ $awaitHelperState == *"Rejected"* ]]; then
      echo "Fatal: Received error when trying to verify state of dashboard-visualiser-jsreport. Error:
       $(docker service ps instant_await-helper --no-trunc --format \"{{.Error}}\")"
      exit 1
    fi
  done

  docker service rm instant_await-helper &
}

remove_config_importer() {
  local complete="false"
  local startTime=$(date +%s)
  local configImporterState=$(docker service ps instant_jsreport-config-importer --format "{{.CurrentState}}")
  until [[ $configImporterState == *"Complete"* ]]; do
    config::timeout_check $startTime "jsreport-config-importer to run"
    sleep 1

    configImporterState=$(docker service ps instant_jsreport-config-importer --format "{{.CurrentState}}")
    if [[ $configImporterState == *"Failed"* ]] || [[ $configImporterState == *"Rejected"* ]]; then
      echo "Fatal: JS Reports config importer failed with error:
       $(docker service ps instant_jsreport-config-importer --no-trunc --format \"{{.Error}}\")"
      exit 1
    fi
  done

  docker service rm instant_jsreport-config-importer
}

RemoveDeadJsrContainers() {
  for i in $(docker ps -aqf name=instant_dashboard-visualiser-jsreport); do
    if [[ $(docker ps -af id="$i" --format "{{.Status}}") == *"Exited"* ]]; then
      docker rm "$i"
    fi
  done
}

CheckFilePermissions() {
  if [[ $(stat -c %a "$COMPOSE_FILE_PATH"/scripts) != "777" ]]; then
    echo "It appears you have not run the 'set-permissions.sh' script before running JS Report with the dev mount attached. Please run 'set-permissions.sh' then try again. Exiting..."
    docker service rm instant_dashboard-visualiser-jsreport
    exit 1
  fi

  for i in $(find "$COMPOSE_FILE_PATH"/scripts/); do
    if [[ $(stat -c %a "$i") != "777" ]]; then
      echo "It appears you have not run the 'set-permissions.sh' script before running JS Report with the dev mount attached. Please run 'set-permissions.sh' then try again. Exiting..."
      docker service rm instant_dashboard-visualiser-jsreport
      exit 1
    fi
  done
  echo "File permissions are correctly set"
  echo "DON'T FORGET TO RUN THE 'set-permissions.sh' SCRIPT AFTER KILLING JS REPORT"
}

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

main() {
  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $JsReportDevComposeParam instant

    docker stack deploy -c "${COMPOSE_FILE_PATH}"/docker-compose.await-helper.yml instant

    echo "Verifying JS Reports service status"
    await_jsr_running

    if [[ "${JS_REPORT_DEV_MOUNT}" == "true" ]]; then
      if [[ -z "${JS_REPORT_PACKAGE_PATH}" ]]; then
        echo "ERROR: JS_REPORT_PACKAGE_PATH environment variable not specified. Please specify JS_REPORT_PACKAGE_PATH as stated in the README."
        exit 1
      fi

      CheckFilePermissions

      echo "Attaching dev mount to JS Report package"
      docker service update --mount-add type=bind,source="${JS_REPORT_PACKAGE_PATH}"/scripts/,target=/app/jsreport/data/ \
        instant_dashboard-visualiser-jsreport &>/dev/null

      RemoveDeadJsrContainers
    else
      config::set_config_digests "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml
      docker stack deploy -c "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml instant

      RemoveConfigImporter
      config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml "jsreport" &>/dev/null

      if [[ "${MODE}" != "dev" ]]; then
        configure_nginx "$@"
      fi
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
