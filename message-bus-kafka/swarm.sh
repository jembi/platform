#!/bin/bash

composeFilePath=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

if [ "$1" == "init" ]; then
    if  [ "$2" == "dev" ]; then
        docker stack deploy -c "$composeFilePath"/docker-compose.yml instant
        sleep 30
        docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.stack.yml instant
    else
        docker stack deploy -c "$composeFilePath"/docker-compose.yml instant
        sleep 30
        docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.prod.yml -c "$composeFilePath"/docker-compose.stack.yml instant
    fi
elif [ "$1" == "up" ]; then
    if  [ "$2" == "dev" ]; then
        docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.stack.yml instant
    else
        docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.prod.yml -c "$composeFilePath"/docker-compose.stack.yml instant
    fi
elif [ "$1" == "down" ]; then
    docker service scale instant_zookeeper=0 instant_kafka=0 instant_kafdrop=0
elif [ "$1" == "destroy" ]; then
    docker service rm instant_zookeeper instant_kafka instant_kafdrop

    echo "Sleep 10 Seconds to allow services to shut down before deleting volumes"
    sleep 10

    docker volume rm instant_kafka-volume
else
    echo "Valid options are: init, up, down, or destroy"
fi
