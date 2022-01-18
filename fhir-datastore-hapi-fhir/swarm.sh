#!/bin/bash

composeFilePath=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

if [ "$1" == "init" ]; then
    if  [ "$2" == "dev" ]; then
        docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.dev.yml -c "$composeFilePath"/docker-compose.stack-0.yml instant

        echo "Sleep 60 seconds to give Postgres time to start up before HAPI-FHIR run"
        sleep 60

        docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.dev.yml -c "$composeFilePath"/docker-compose.stack-1.yml instant
    else
        docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.prod.yml -c "$composeFilePath"/docker-compose.stack-0.yml instant

        echo "Sleep 60 seconds to give Postgres time to start up before HAPI-FHIR run"
        sleep 60

        docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.prod.yml -c "$composeFilePath"/docker-compose.stack-1.yml instant
    fi
elif [ "$1" == "up" ]; then
    if [ "$2" == "dev" ]; then
        docker stack deploy -c "$composeFilePath"/docker-compose.mongo.yml -c "$composeFilePath"/docker-compose.mongo.dev.yml instant
        sleep 20
        docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.dev.yml -c "$composeFilePath"/docker-compose.stack-1.yml instant
    else
        docker stack deploy -c "$composeFilePath"/docker-compose.mongo.yml instant
        sleep 20
        docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.stack-1.yml instant
    fi 
elif [ "$1" == "down" ]; then
    docker service scale instant_hapi-fhir=0 instant_hapi-db=0
elif [ "$1" == "destroy" ]; then
    docker service rm instant_hapi-fhir instant_hapi-db

    echo "Sleep 10 Seconds to allow services to shut down before deleting volumes"
    sleep 10

    docker volume rm instant_hapi-db-volume
else
    echo "Valid options are: init, up, down, or destroy"
fi
