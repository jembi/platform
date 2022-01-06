#!/bin/bash

composeFilePath=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

if [ "$1" == "init" ]; then
    docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.stack.yml instant
elif [ "$1" == "up" ]; then
    docker stack deploy -c "$composeFilePath"/docker-compose.yml instant
elif [ "$1" == "down" ]; then
    docker service scale instant_logstash=0 instant_reprocess-mediator=0
elif [ "$1" == "destroy" ]; then
    docker service rm instant_logstash instant_reprocess-mediator
    sleep 15
    docker volume rm logstash-pipeline logstash-config
else
    echo "Valid options are: init, up, down, or destroy"
fi
