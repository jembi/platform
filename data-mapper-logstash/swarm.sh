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

AwaitContainerStartup() {
  echo "Waiting for logstash container to start up..."

  local warningTime=60
  local errorTime=300
  local timer=0

  until [[ -n $(docker ps -qlf name=instant_data-mapper-logstash) ]]; do
    if [[ "$timer" == "$warningTime" ]]; then
      echo "Warning: container is taking unusually long to start"
    fi
    if [[ "$timer" == "$errorTime" ]]; then
      echo "Fatal: Logstash container took too long to start up"
      exit 124 # exit code for timeout is 124
    fi
    sleep 1
    timer=$((timer + 1))
  done
  echo "Logstash container started up"
}

AwaitContainerReady() {
  echo "Waiting for logstash container to be in ready state..."

  local warningTime=60
  local errorTime=300
  local timer=0

  until [[ "$(docker inspect -f '{{.State.Status}}' $(docker ps -qlf name=instant_data-mapper-logstash))" = "running" ]]; do
    if [[ "$timer" == "$warningTime" ]]; then
      echo "Warning: container is taking unusually long to start"
    fi
    if [[ "$timer" == "$errorTime" ]]; then
      echo "Fatal: Logstash container took too long to start up"
      exit 124 # exit code for timeout is 124
    fi
    sleep 1
    timer=$((timer + 1))
  done
  echo "Logstash container is in ready state"
}

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

  AwaitContainerStartup
  AwaitContainerReady

  config::copy_shared_configs "$COMPOSE_FILE_PATH"/package-metadata.json /usr/share/logstash/

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
