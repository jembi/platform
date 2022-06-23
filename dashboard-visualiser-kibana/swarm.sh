#!/bin/bash

readonly ACTION=$1
readonly MODE=$2

TIMESTAMP="$(date "+%Y%m%d%H%M%S")"
readonly TIMESTAMP

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)
readonly COMPOSE_FILE_PATH

ROOT_PATH="${COMPOSE_FILE_PATH}/.."
readonly ROOT_PATH

. "${ROOT_PATH}/utils/config-utils.sh"

configure_nginx() {

  if [[ "${INSECURE}" == "true" ]]; then
    docker config create --label name=nginx "${TIMESTAMP}-http-kibana-insecure.conf" "${COMPOSE_FILE_PATH}/config/http-kibana-insecure.conf"
    echo "Updating nginx service: adding kibana config file..."
    if ! docker service update \
      --config-add source="${TIMESTAMP}-http-kibana-insecure.conf",target=/etc/nginx/conf.d/http-kibana-insecure.conf \
      instant_reverse-proxy-nginx >/dev/null; then
      echo "Error updating nginx service"
      exit 1
    fi
    echo "Done updating nginx service"
  else
    docker config create --label name=nginx "${TIMESTAMP}-http-kibana-secure.conf" "${COMPOSE_FILE_PATH}/config/http-kibana-secure.conf"
    echo "Updating nginx service: adding kibana config file..."
    if ! docker service update \
      --config-add source="${TIMESTAMP}-http-kibana-secure.conf",target=/etc/nginx/conf.d/http-kibana-secure.conf \
      instant_reverse-proxy-nginx >/dev/null; then
      echo "Error updating nginx service"
      exit 1
    fi
    echo "Done updating nginx service"
  fi
}

main() {
  if [[ "$MODE" == "dev" ]]; then
    printf "\nRunning Dashboard Visualiser Kibana package in DEV mode\n"
    kibana_dev_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
  else
    printf "\nRunning Dashboard Visualiser Kibana package in PROD mode\n"
    kibana_dev_compose_param=""
  fi

  if [[ "$ACTION" == "init" ]] || [[ "$ACTION" == "up" ]]; then
    docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $kibana_dev_compose_param instant

    config::await_service_running "dashboard-visualiser-kibana" "${COMPOSE_FILE_PATH}/docker-compose.await-helper.yml" "$KIBANA_INSTANCES"

    echo "Setting config digests"
    config::set_config_digests "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml
    docker stack deploy -c "${COMPOSE_FILE_PATH}"/importer/docker-compose.config.yml instant

    config::remove_config_importer "kibana-config-importer"
    config::remove_stale_service_configs "$COMPOSE_FILE_PATH"/importer/docker-compose.config.yml "kibana"

    if [[ "${MODE}" != "dev" ]]; then
      configure_nginx "$@"
    fi

  elif [[ "$ACTION" == "down" ]]; then
    docker service scale instant_dashboard-visualiser-kibana=0
  elif [[ "$ACTION" == "destroy" ]]; then
    docker service rm instant_dashboard-visualiser-kibana instant_await-helper instant_kibana-config-importer &>/dev/null
  else
    echo "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
