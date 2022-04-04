#!/bin/bash

STATEFUL_NODES=${STATEFUL_NODES:-"cluster"}

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)

if [[ "$STATEFUL_NODES" == "cluster" ]]; then
  printf "\nRunning Analytics Datastore Elastic Search package in Cluster node mode\n"
  JsReportsClusterComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.cluster.yml"
else
  printf "\nRunning Analytics Datastore Elastic Search package in Single node mode\n"
  JsReportsClusterComposeParam=""
fi

if [[ "$2" == "dev" ]]; then
  printf "\nRunning JS Reports package in DEV mode\n"
  JsReportDevComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  printf "\nRunning JS Reports package in PROD mode\n"
  JsReportDevComposeParam=""
fi

if [[ "$1" == "init" ]]; then
  docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $JsReportDevComposeParam $JsReportsClusterComposeParam instant
elif [[ "$1" == "up" ]]; then
  docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $JsReportDevComposeParam $JsReportsClusterComposeParam instant
elif [[ "$1" == "down" ]]; then
  docker service scale instant_dashboard-visualiser-jsreport=0
elif [[ "$1" == "destroy" ]]; then
  docker service rm instant_dashboard-visualiser-jsreport
  docker config rm instant_jsreport-export.jsrexport
else
  echo "Valid options are: init, up, down, or destroy"
fi
