#!/bin/bash

composeFilePath=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

if [ "$PROD" == "true" ]; then
    printf "\nRunning data-analytics package in PROD mode\n"
    devComposeParam=""
else
    printf "\nRunning data-analytics package in DEV mode\n"
    devComposeParam="-f ${composeFilePath}/docker-compose.dev.yml"
fi

if [ "$1" == "init" ]; then
    docker-compose -p instant -f "$composeFilePath"/docker-compose.yml $devComposeParam up -d es-analytics

    echo "Waiting for elasticsearch to start before automatically setting built-in passwords..."
    sleep 40
    apt-get install -y expect >/dev/null 2>&1
    echo "Setting passwords..."
    "$composeFilePath"/set-pwds.exp
    echo "Done"

    docker-compose -p instant -f "$composeFilePath"/docker-compose.yml $devComposeParam up -d
elif [ "$1" == "up" ]; then
    docker-compose -p instant -f "$composeFilePath"/docker-compose.yml $devComposeParam up -d
elif [ "$1" == "down" ]; then
    docker-compose -p instant -f "$composeFilePath"/docker-compose.yml stop
elif [ "$1" == "destroy" ]; then
    docker-compose -p instant -f "$composeFilePath"/docker-compose.yml down -v
else
    echo "Valid options are: init, up, down, or destroy"
fi
