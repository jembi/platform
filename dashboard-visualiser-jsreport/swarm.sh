#!/bin/bash

STATEFUL_NODES=${STATEFUL_NODES:-"cluster"}

ComposeFilePath=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)

if [[ "$2" == "dev" ]]; then
  printf "\nRunning JS Reports package in DEV mode\n"
  JsReportDevComposeParam="-c ${ComposeFilePath}/docker-compose.dev.yml"
else
  printf "\nRunning JS Reports package in PROD mode\n"
  JsReportDevComposeParam=""
fi

if [[ "$1" == "init" ]]; then
  docker stack deploy -c "$ComposeFilePath"/docker-compose.yml $JsReportDevComposeParam instant
elif [[ "$1" == "up" ]]; then
  docker stack deploy -c "$ComposeFilePath"/docker-compose.yml $JsReportDevComposeParam instant
elif [[ "$1" == "down" ]]; then
  docker service scale instant_dashboard-visualiser-jsreport=0
elif [[ "$1" == "destroy" ]]; then
  docker service rm instant_dashboard-visualiser-jsreport
else
  echo "Valid options are: init, up, down, or destroy"
fi
