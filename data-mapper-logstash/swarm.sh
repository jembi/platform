#!/bin/bash

Action=$1
Mode=$2

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)

if [[ "$Mode" == "dev" ]]; then
  printf "\nRunning Data Mapper Logstash package in DEV mode\n"
  LogstashDevComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  printf "\nRunning Data Mapper Logstash package in PROD mode\n"
  LogstashDevComposeParam=""
fi

if [[ "$Action" == "init" ]] || [[ "$Action" == "up" ]]; then
  apt install wget -y
  wget https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq
  . "$COMPOSE_FILE_PATH"/config-raft.sh "$COMPOSE_FILE_PATH"/docker-compose.yml

  docker stack deploy --prune -c "$COMPOSE_FILE_PATH"/docker-compose.yml $LogstashDevComposeParam instant
elif [[ "$Action" == "down" ]]; then
  docker service scale instant_data-mapper-logstash=0
elif [[ "$Action" == "destroy" ]]; then
  docker service rm instant_data-mapper-logstash
else
  echo "Valid options are: init, up, down, or destroy"
fi
