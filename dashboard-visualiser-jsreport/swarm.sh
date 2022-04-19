#!/bin/bash

Action=$1
Mode=$2

STATEFUL_NODES=${STATEFUL_NODES:-"cluster"}

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)

ROOT_PATH="${COMPOSE_FILE_PATH}/.."
. "${ROOT_PATH}/utils/config-utils.sh"

if [[ "$Mode" == "dev" ]]; then
  printf "\nRunning JS Reports package in DEV mode\n"
  JsReportDevComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  printf "\nRunning JS Reports package in PROD mode\n"
  JsReportDevComposeParam=""
fi

AwaitJsrRunning() {
  local startTime=$(date +%s)
  until [[ $(docker service ls -f name=instant_dashboard-visualiser-jsreport --format "{{.Replicas}}") == *"${JS_REPORT_INSTANCES}/${JS_REPORT_INSTANCES}"* ]]; do
    config::timeout_check $startTime "dashboard-visualiser-jsreport to start" "60" "300"
    sleep 1
  done

  local awaitHelperState=$(docker service ps instant_await-helper --format "{{.CurrentState}}")
  until [[ $awaitHelperState == *"Complete"* ]]; do
    config::timeout_check $startTime "dashboard-visualiser-jsreport status check" "60" "300"
    sleep 1

    awaitHelperState=$(docker service ps instant_await-helper --format "{{.CurrentState}}")
    if [[ $awaitHelperState == *"Failed"* ]] || [[ $awaitHelperState == *"Rejected"* ]]; then
      echo "Fatal: Received error when trying to verify state of dashboard-visualiser-jsreport. Error:
       $(docker service ps instant_await-helper --no-trunc --format \"{{.Error}}\")"
      exit 1
    fi
  done

  docker service rm instant_await-helper
}

RemoveConfigImporter() {
  local complete="false"
  local startTime=$(date +%s)
  local configImporterState=$(docker service ps instant_jsreport-config-importer --format "{{.CurrentState}}")
  until [[ $configImporterState == *"Complete"* ]]; do
    config::timeout_check $startTime "jsreport-config-importer to run" "60" "300"
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

if [[ "$Action" == "init" ]] || [[ "$Action" == "up" ]]; then
  docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $JsReportDevComposeParam instant

  docker stack deploy -c "${COMPOSE_FILE_PATH}"/docker-compose.await-helper.yml instant

  echo "Verifying JS Reports service status"
  AwaitJsrRunning

  docker stack deploy -c "${COMPOSE_FILE_PATH}"/importer/docker-compose.config.yml instant

  RemoveConfigImporter
  docker config rm instant_jsreport-config-importer-export.jsrexport
elif [[ "$Action" == "down" ]]; then
  docker service scale instant_dashboard-visualiser-jsreport=0
elif [[ "$Action" == "destroy" ]]; then
  docker service rm instant_dashboard-visualiser-jsreport instant_jsreport-config-importer instant_await-helper
  docker config rm instant_jsreport-config-importer-export.jsrexport
else
  echo "Valid options are: init, up, down, or destroy"
fi
