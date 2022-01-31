#!/bin/bash

composeFilePath=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

if [ "$1" == "init" ]; then
    docker stack deploy -c "$composeFilePath"/docker-compose.yml instant
elif [ "$1" == "up" ]; then
    docker stack deploy -c "$composeFilePath"/docker-compose.yml instant
elif [ "$1" == "down" ]; then
    docker service scale instant_reverse-proxy=0
    docker service scale instant_ofelia=0
elif [ "$1" == "destroy" ]; then
    docker service rm instant_reverse-proxy
    docker service rm instant_ofelia
else
    echo "Valid options are: init, up, down, or destroy"
fi
