#!/bin/bash

composeFilePath=$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)

if [ "$2" == "dev" ]; then
  printf "\nRunning Dashboard Visualiser Kibana package in DEV mode\n"
  kibanaDevComposeParam="-c ${composeFilePath}/docker-compose.dev.yml"
else
  printf "\nRunning Dashboard Visualiser Kibana package in PROD mode\n"
  kibanaDevComposeParam=""
fi

if [ "$1" == "init" ] || [ "$1" == "up" ]; then
  docker stack deploy -c "$composeFilePath"/docker-compose.yml $kibanaDevComposeParam instant
elif [ "$1" == "down" ]; then
  docker service scale instant_dashboard-visualiser-kibana=0
elif [ "$1" == "destroy" ]; then
  docker service rm instant_dashboard-visualiser-kibana
else
  echo "Valid options are: init, up, down, or destroy"
fi
