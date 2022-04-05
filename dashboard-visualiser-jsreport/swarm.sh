#!/bin/bash

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)

VerifyJsReport() {
  local startTime=$(date +%s)
  until [[ $(docker service ls -f name=instant_dashboard-visualiser-jsreport --format "{{.Replicas}}") == *"1/1"* ]]; do
    TimeoutCheck $startTime "dashboard-visualiser-jsreport to start"
    sleep 1
  done

  local awaitHelperState=$(docker service ps instant_await-helper --format "{{.CurrentState}}")
  until [[ $awaitHelperState == *"Complete"* ]]; do
    TimeoutCheck $startTime "dashboard-visualiser-jsreport check"
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

TimeoutCheck() {
  local startTime=$(($1))
  local message=$2
  local timeDiff=$(($(date +%s) - $startTime))
  if [[ $timeDiff -ge 60 ]] && [[ $timeDiff -lt 61 ]]; then
    echo "Warning: Waited 1 minute for $message. This is taking longer than it should..."
  elif [[ $timeDiff -ge 120 ]]; then
    echo "Fatal: Waited 2 minutes for $message. Exiting..."
    exit 1
  fi
}

if [[ "$2" == "dev" ]]; then
  printf "\nRunning JS Reports package in DEV mode\n"
  JsReportDevComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  printf "\nRunning JS Reports package in PROD mode\n"
  JsReportDevComposeParam=""
fi

if [[ "$1" == "init" ]]; then
  docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml -c "$COMPOSE_FILE_PATH"/docker-compose.stack-0.yml $JsReportDevComposeParam instant
  docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.await-helper.yml instant

  echo "Waiting for JS Reports to start before loading configs..."
  VerifyJsReport

  echo "Importing JS Reports config files."
  docker exec -i $(docker ps -qf name=instant_dashboard-visualiser-jsreport) jsreport import export.jsrexport
  docker exec -iw /app/jsreport/data $(docker ps -qf name=instant_dashboard-visualiser-jsreport) sh -c 'chown 100 $(ls) && chgrp 101 $(ls)'

  docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml -c "$COMPOSE_FILE_PATH"/docker-compose.stack-1.yml $JsReportDevComposeParam instant
elif [[ "$1" == "up" ]]; then
  docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $JsReportDevComposeParam $JsReportsClusterComposeParam instant
elif [[ "$1" == "down" ]]; then
  docker service scale instant_dashboard-visualiser-jsreport=0
elif [[ "$1" == "destroy" ]]; then
  docker service rm instant_dashboard-visualiser-jsreport instant_await-helper
  docker config rm instant_jsreport-export.jsrexport
else
  echo "Valid options are: init, up, down, or destroy"
fi
