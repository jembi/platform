#!/bin/bash

composeFilePath=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

if [ "$1" == "init" ]; then
  docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.prod.yml instant
elif [ "$1" == "up" ]; then
  docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.prod.yml instant
elif [ "$1" == "down" ]; then
    docker service rm instant_metricbeat
elif [ "$1" == "destroy" ]; then
    docker service rm instant_metricbeat
else
    echo "Valid options are: init, up, down, or destroy"
fi
