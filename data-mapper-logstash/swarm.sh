#!/bin/bash

# Arguments
Action=$1
Mode=$2

readonly LOGSTASH_DEV_MOUNT=$LOGSTASH_DEV_MOUNT

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)

# Import libraries
ROOT_PATH="${COMPOSE_FILE_PATH}/.."
. "${ROOT_PATH}/utils/config-utils.sh"
. "${ROOT_PATH}/utils/log.sh"

AwaitContainerStartup() {
  log info "Waiting for logstash container to start up..."

  local warningTime=60
  local errorTime=300
  local timer=0

  until [[ -n $(docker ps -qlf name=instant_data-mapper-logstash) ]]; do
    if [[ "$timer" == "$warningTime" ]]; then
      log warn "Container is taking unusually long to start"
    elif [[ "$timer" == "$errorTime" ]]; then
      log error "Logstash container took too long to start up"
      exit 124 # exit code for timeout is 124
    fi
    sleep 1
    timer=$((timer + 1))
  done
  log info "Done"
}

AwaitContainerReady() {
  log info "Waiting for logstash container to be in ready state..."

  local warningTime=60
  local errorTime=300
  local timer=0

  until [[ "$(docker inspect -f '{{.State.Status}}' $(docker ps -qlf name=instant_data-mapper-logstash))" = "running" ]]; do
    if [[ "$timer" == "$warningTime" ]]; then
      log warn "Container is taking unusually long to start"
    elif [[ "$timer" == "$errorTime" ]]; then
      log error "Logstash container took too long to start up"
      exit 124 # exit code for timeout is 124
    fi
    sleep 1
    timer=$((timer + 1))
  done
  log info "Done"
}

if [[ "$Mode" == "dev" ]]; then
  log info "Running Data Mapper Logstash package in DEV mode"
  LogstashDevComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  log info "Running Data Mapper Logstash package in PROD mode"
  LogstashDevComposeParam=""
fi

if [[ "$LOGSTASH_DEV_MOUNT" == "true" ]]; then
  if [[ -z $LOGSTASH_PACKAGE_PATH ]]; then
    log error "LOGSTASH_PACKAGE_PATH environment variable not specified. Please specify LOGSTASH_PACKAGE_PATH as stated in the README."
    exit 1
  fi

  log info "Running Data Mapper Logstash package with dev mount"
  LogstashDevMountComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.dev-mnt.yml"
else
  LogstashDevMountComposeParam=""
fi

if [[ "$Action" == "init" ]] || [[ "$Action" == "up" ]]; then

  config::set_config_digests "$COMPOSE_FILE_PATH"/docker-compose.yml

  docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $LogstashDevComposeParam $LogstashDevMountComposeParam instant &&
    log debug "${prev_cmd}" ||
    log error "${prev_cmd}"

  AwaitContainerStartup
  AwaitContainerReady

  if [[ "$LOGSTASH_DEV_MOUNT" != "true" ]]; then
    config::copy_shared_configs "$COMPOSE_FILE_PATH"/package-metadata.json /usr/share/logstash/
  fi

  log info "Removing stale configs..."
  config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/docker-compose.yml "logstash"

  log info "Done"
elif [[ "$Action" == "down" ]]; then
  docker service scale instant_data-mapper-logstash=0 &&
    log debug "${prev_cmd}" ||
    log error "${prev_cmd}"
elif [[ "$Action" == "destroy" ]]; then
  docker service rm instant_data-mapper-logstash &&
    log debug "${prev_cmd}" ||
    log error "${prev_cmd}"
else
  log error "Valid options are: init, up, down, or destroy"
fi
