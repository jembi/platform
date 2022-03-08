#!/bin/bash

composeFilePath=$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)

if [ "$2" == "dev" ]; then
  printf "\nRunning Data Mapper Logstash package in DEV mode\n"
  logstashDevComposeParam="-c ${composeFilePath}/docker-compose.dev.yml"
else
  printf "\nRunning Data Mapper Logstash package in PROD mode\n"
  logstashDevComposeParam=""
fi

if [ "$1" == "init" ] || [ "$1" == "up" ]; then
  docker stack deploy -c "$composeFilePath"/docker-compose.yml $logstashDevComposeParam instant
elif [ "$1" == "down" ]; then
  docker service scale instant_data-mapper-logstash=0
elif [ "$1" == "destroy" ]; then
  docker service rm instant_data-mapper-logstash
else
  echo "Valid options are: init, up, down, or destroy"
fi
