#!/bin/bash

composeFilePath=$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)

if [ "$1" == "init" ]; then
  docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.dev.yml instant
elif [ "$1" == "up" ]; then
  docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.dev.yml instant
elif [ "$1" == "down" ]; then
  docker service scale instant_prometheus=0 instant_grafana=0
elif [ "$1" == "destroy" ]; then
  docker service rm instant_prometheus instant_grafana
  docker config rm instant_prometheus.config
else
  echo "Valid options are: init, up, down, or destroy"
fi
