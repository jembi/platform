#!/bin/bash

Action=$1
Mode=$2

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)

if [[ "$Mode" == "dev" ]]; then
  printf "\nRunning Dashboard Visualiser Kibana package in DEV mode\n"
  KibanaDevComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  printf "\nRunning Dashboard Visualiser Kibana package in PROD mode\n"
  KibanaDevComposeParam=""
fi

if [[ "$Action" == "init" ]] || [[ "$Action" == "up" ]]; then
  docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $KibanaDevComposeParam instant
elif [[ "$Action" == "down" ]]; then
  docker service scale instant_dashboard-visualiser-kibana=0
elif [[ "$Action" == "destroy" ]]; then
  docker service rm instant_dashboard-visualiser-kibana
else
  echo "Valid options are: init, up, down, or destroy"
fi
