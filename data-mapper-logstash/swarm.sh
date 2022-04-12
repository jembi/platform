#!/bin/bash

# Arguments
Action=$1
Mode=$2

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)

# Import libraries
ROOT_PATH="${COMPOSE_FILE_PATH}/.."
. "${ROOT_PATH}/utils/config-utils.sh"

if [[ "$Mode" == "dev" ]]; then
  echo -e "\nRunning Data Mapper Logstash package in DEV mode\n"
  LogstashDevComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  echo -e "\nRunning Data Mapper Logstash package in PROD mode\n"
  LogstashDevComposeParam=""
fi

if [[ "$Action" == "init" ]] || [[ "$Action" == "up" ]]; then

  config::set_config_digests "$COMPOSE_FILE_PATH"/docker-compose.yml

  docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $LogstashDevComposeParam instant

  echo "Removing stale configs..."
  config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/docker-compose.yml "logstash"

  echo "Done"
elif [[ "$Action" == "down" ]]; then
  docker service scale instant_data-mapper-logstash=0
elif [[ "$Action" == "destroy" ]]; then
  docker service rm instant_data-mapper-logstash
else
  echo "Valid options are: init, up, down, or destroy"
fi
