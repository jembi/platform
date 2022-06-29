#!/bin/bash

composeFilePath=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)

if [ "$1" == "init" ]; then
  if [ "$2" == "dev" ]; then
    docker stack deploy -c "$composeFilePath"/docker-compose.yml instant
  else
    docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.prod.yml instant
  fi
elif [ "$1" == "up" ]; then
  if [ "$2" == "dev" ]; then
    docker stack deploy -c "$composeFilePath"/docker-compose.yml instant
  else
    docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.prod.yml instant
  fi
elif [ "$1" == "down" ]; then
  docker service scale instant_hapi-proxy=0
elif [ "$1" == "destroy" ]; then
  docker service rm instant_hapi-proxy
else
  log error "Valid options are: init, up, down, or destroy"
fi
