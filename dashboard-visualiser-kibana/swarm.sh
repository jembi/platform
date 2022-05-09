#!/bin/bash

Action=$1
Mode=$2

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)
readonly COMPOSE_FILE_PATH

ROOT_PATH="${COMPOSE_FILE_PATH}/.."
readonly ROOT_PATH
. "${ROOT_PATH}/utils/config-utils.sh"

if [[ "$Mode" == "dev" ]]; then
  printf "\nRunning Dashboard Visualiser Kibana package in DEV mode\n"
  kibana_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  printf "\nRunning Dashboard Visualiser Kibana package in PROD mode\n"
  kibana_dev_compose_param=""
fi

remove_config_importer() {
  local start_time
  start_time=$(date +%s)
  local config_importer_state
  config_importer_state=$(docker service ps instant_kibana-config-importer --format "{{.CurrentState}}")
  until [[ $config_importer_state == *"Complete"* ]]; do
    config::timeout_check "$start_time" "kibana-config-importer to run"
    sleep 1

    config_importer_state=$(docker service ps instant_kibana-config-importer --format "{{.CurrentState}}")
    if [[ $config_importer_state == *"Failed"* ]] || [[ $config_importer_state == *"Rejected"* ]]; then
      echo "Fatal: Kibana config importer failed with error:
       $(docker service ps instant_kibana-config-importer --no-trunc --format '{{.Error}}')"
      exit 1
    fi
  done

  docker service rm instant_kibana-config-importer
}

if [[ "$Action" == "init" ]] || [[ "$Action" == "up" ]]; then
  docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $kibana_dev_compose_param instant

  config::await_service_running "dashboard-visualiser-kibana" "${COMPOSE_FILE_PATH}/docker-compose.await-helper.yml" "$KIBANA_INSTANCES"

  echo "Setting config digests"
  config::set_config_digests "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml
  docker stack deploy -c "${COMPOSE_FILE_PATH}"/importer/docker-compose.config.yml instant

  remove_config_importer
  config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml "jsreport"
elif [[ "$Action" == "down" ]]; then
  docker service scale instant_dashboard-visualiser-kibana=0
elif [[ "$Action" == "destroy" ]]; then
  docker service rm instant_dashboard-visualiser-kibana instant_await-helper instant_kibana-config-importer &>/dev/null
else
  echo "Valid options are: init, up, down, or destroy"
fi
