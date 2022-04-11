#!/bin/bash

Action=$1
Mode=$2

STATEFUL_NODES=${STATEFUL_NODES:-"cluster"}

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)

if [[ "$Mode" == "dev" ]]; then
  printf "\nRunning Metricbeat package in DEV mode\n"
  MetricBeatDevComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  printf "\nRunning Metricbeat package in PROD mode\n"
  MetricBeatDevComposeParam=""
fi

if [[ "$Action" == "init" ]] || [[ "$Action" == "up" ]]; then
  docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $MetricBeatDevComposeParam instant
elif [[ "$Action" == "down" ]]; then
  docker service scale instant_elastic-monitoring-metricbeat=0
elif [[ "$Action" == "destroy" ]]; then
  docker service rm instant_elastic-monitoring-metricbeat
else
  echo "Valid options are: init, up, down, or destroy"
fi
