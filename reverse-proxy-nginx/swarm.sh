#!/bin/bash

# Constants
readonly ACTION=$1
readonly MODE=$2

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)
readonly COMPOSE_FILE_PATH

TIMESTAMP="$(date "+%Y%m%d%H%M%S")"
readonly TIMESTAMP
readonly TIMESTAMPED_NGINX="${TIMESTAMP}-nginx.conf"

# Import libraries
ROOT_PATH="${COMPOSE_FILE_PATH}/.."
. "${ROOT_PATH}/utils/log.sh"
. "${ROOT_PATH}/utils/docker-utils.sh"
. "${ROOT_PATH}/utils/config-utils.sh"

main() {
  if [[ "${MODE}" == "dev" ]]; then
    log info "Not including reverse proxy as we are running DEV mode"
    exit 0
  fi
  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    if [[ "${INSECURE}" == "true" ]]; then
      log info "Running reverse-proxy package in INSECURE mode"

      config::generate_service_configs reverse-proxy-nginx /etc/nginx/conf.d "${COMPOSE_FILE_PATH}/package-conf-insecure" "${COMPOSE_FILE_PATH}" nginx
      nginx_temp_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.tmp.yml"
      try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml $nginx_temp_compose_param --with-registry-auth instant" "Failed to deploy nginx"

      if [ "${INSECURE_PORTS}" != "" ]; then
        IFS='-' read -ra PORTS <<<"$INSECURE_PORTS"
        local portsArray=()
        for i in "${PORTS[@]}"; do
          IFS=':' read -ra PORTS_SPLIT <<<"$i"
          if [ "${PORTS_SPLIT[0]}" != "" ] && [ "${PORTS_SPLIT[1]}" != "" ]; then
            portsArray+=(--publish-add "published=${PORTS_SPLIT[0]},target=${PORTS_SPLIT[1]}")
            log info "Exposing ports: published=%s,target=%s\n" "${PORTS_SPLIT[0]}" "${PORTS_SPLIT[1]}"
          else
            log info "Failed to expose ports: published=%s,target=%s\n" "${PORTS_SPLIT[0]}" "${PORTS_SPLIT[1]}"
          fi
        done
        log info "Updating nginx service with configured ports..."
        try "docker service update ${portsArray[*]} instant_reverse-proxy-nginx" "Error updating nginx service."

        log info "Done updating nginx service"
      fi

      try "docker config create --label name=nginx ${TIMESTAMPED_NGINX} ${COMPOSE_FILE_PATH}/config/nginx-temp-insecure.conf" "Failed to create nginx insecure config"

      log info "Updating nginx service: adding config file..."
      try "docker service update --config-add source=${TIMESTAMPED_NGINX},target=/etc/nginx/nginx.conf instant_reverse-proxy-nginx" "Error updating nginx service"

      log info "Done updating nginx service"
    else
      log info "Running reverse-proxy package in SECURE mode"

      config::generate_service_configs reverse-proxy-nginx /etc/nginx/conf.d "${COMPOSE_FILE_PATH}/package-conf-secure" "${COMPOSE_FILE_PATH}" nginx
      nginx_temp_compose_param="-c ${COMPOSE_FILE_PATH}/docker-compose.tmp.yml"
      try "docker stack deploy -c ${COMPOSE_FILE_PATH}/docker-compose.yml $nginx_temp_compose_param --with-registry-auth instant" "Failed to deploy nginx"

      local domain_args=()
      if [ -n "$SUBDOMAINS" ]; then
        domain_args=(-d "${DOMAIN_NAME},${SUBDOMAINS}")
      else
        domain_args=(-d "${DOMAIN_NAME}")
      fi

      log info "Setting up Nginx reverse-proxy with the following domain name: ${DOMAIN_NAME}"
      #Generate dummy certificate
      try "docker run --rm \
        --network host \
        --name letsencrypt \
        -v dummy-data-certbot-conf:/etc/letsencrypt/archive/${DOMAIN_NAME} \
        certbot/certbot:v1.23.0 certonly -n \
        -m ${RENEWAL_EMAIL} \
        --staging \
        ${domain_args[*]} \
        --standalone --agree-tos" "Failed to create certificate network"

      docker run --rm --network host --name certbot-helper -w /temp \
        -v dummy-data-certbot-conf:/temp-certificates \
        -v instant:/temp busybox sh \
        -c "rm -rf certificates; mkdir certificates; cp -r /temp-certificates/* /temp/certificates"

      try "docker volume rm dummy-data-certbot-conf" "Failed to remove volume dummy-data-certbot-conf"

      try "docker secret create --label name=nginx ${TIMESTAMP}-fullchain.pem /instant/certificates/fullchain1.pem" "Failed to create fullchain secret"
      try "docker secret create --label name=nginx ${TIMESTAMP}-privkey.pem /instant/certificates/privkey1.pem" "Failed to create privkey1 secret"

      #Create copy of nginx-temp-secure.conf to ensure sed will always work correctly
      cp "${COMPOSE_FILE_PATH}"/config/nginx-temp-secure.conf "${COMPOSE_FILE_PATH}"/config/nginx.conf
      sed -i "s/domain_name/${DOMAIN_NAME}/g;" "${COMPOSE_FILE_PATH}"/config/nginx.conf

      local nginx_network_exists
      nginx_network_exists=$(docker network ls --filter name=cert-renewal-network --format '{{.Name}}')
      #Do not create docker network if it exists
      if [[ -z "${nginx_network_exists}" ]]; then
        try "docker network create -d overlay --attachable cert-renewal-network" "Failed to create cert-renewal-network network"
      fi

      #Update nginx to use the dummy certificate
      try "docker config create --label name=nginx ${TIMESTAMPED_NGINX} ${COMPOSE_FILE_PATH}/config/nginx.conf" "Failed to create nginx config"

      log info "Updating nginx service: adding config for dummy certificates..."
      try "docker service update \
        --config-add source=${TIMESTAMPED_NGINX},target=/etc/nginx/nginx.conf \
        --secret-add source=${TIMESTAMP}-fullchain.pem,target=/run/secrets/fullchain.pem \
        --secret-add source=${TIMESTAMP}-privkey.pem,target=/run/secrets/privkey.pem \
        --network-add name=cert-renewal-network,alias=cert-renewal-network \
        --publish-add published=80,target=80 \
        --publish-add published=443,target=443 \
        instant_reverse-proxy-nginx" "Error updating nginx service"

      log info "Done updating nginx service"

      local staging_args=""
      if [ "${STAGING}" == "true" ]; then
        staging_args="--staging"
      fi

      #Generate real certificate
      try "docker run --rm \
        -p 8083:80 \
        -p 8443:443 \
        --name certbot \
        --network cert-renewal-network \
        -v data-certbot-conf:/etc/letsencrypt/archive/${DOMAIN_NAME} \
        certbot/certbot:v1.23.0 certonly -n \
        --standalone \
        ${staging_args} \
        -m ${RENEWAL_EMAIL} \
        ${domain_args[*]} \
        --agree-tos" "Failed to generate certificate"

      try "docker run --rm --network host --name certbot-helper -w /temp \
        -v data-certbot-conf:/temp-certificates \
        -v instant:/temp busybox sh \
        -c \"rm -rf certificates; mkdir -p certificates; cp -r /temp-certificates/* /temp/certificates\"" "Failed to transfer certificate"

      try "docker volume rm data-certbot-conf" "Failed to remove data-certbot-conf volume"

      local new_timestamp
      new_timestamp="$(date "+%Y%m%d%H%M%S")"
      try "docker secret create --label name=nginx ${new_timestamp}-fullchain.pem /instant/certificates/fullchain1.pem" "Failed to create fullchain nginx secret"
      try "docker secret create --label name=nginx ${new_timestamp}-privkey.pem /instant/certificates/privkey1.pem" "Failed to create privkey1 nginx secret"

      local curr_full_chain_name
      curr_full_chain_name=$(docker service inspect instant_reverse-proxy-nginx --format "{{(index .Spec.TaskTemplate.ContainerSpec.Secrets 0).SecretName}}")
      local curr_priv_key_name
      curr_priv_key_name=$(docker service inspect instant_reverse-proxy-nginx --format "{{(index .Spec.TaskTemplate.ContainerSpec.Secrets 1).SecretName}}")

      log info "Updating nginx service: adding secrets for generated certificates"
      try "docker service update \
        --secret-rm ${curr_full_chain_name} \
        --secret-rm ${curr_priv_key_name} \
        --secret-add source=${new_timestamp}-fullchain.pem,target=/run/secrets/fullchain.pem \
        --secret-add source=${new_timestamp}-privkey.pem,target=/run/secrets/privkey.pem \
        instant_reverse-proxy-nginx" "Error updating nginx service"
      log info "Done updating nginx service"
    fi

    docker::deploy_sanity reverse-proxy-nginx
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down services..."
    try "docker service scale instant_reverse-proxy-nginx=0" "Error scaling down services"
    log info "Done scaling down services"
  elif [[ "${ACTION}" == "destroy" ]]; then
    try "docker service rm instant_reverse-proxy-nginx" "Failed to remove instant_reverse-proxy-nginx"

    mapfile -t nginx_secrets < <(docker secret ls -qf label=name=nginx)
    if [[ "${#nginx_secrets[@]}" -ne 0 ]]; then
      try "docker secret rm ${nginx_secrets[*]}" "Failed to remove nginx secrets"
    fi

    mapfile -t nginx_configs < <(docker config ls -qf label=name=nginx)
    if [[ "${#nginx_configs[@]}" -ne 0 ]]; then
      try "docker config rm ${nginx_configs[*]}" "Failed to remove nginx configs"
    fi

    mapfile -t nginx_network < <(docker network ls -qf name=cert-renewal-network)
    if [[ "${#nginx_network}" -ne 0 ]]; then
      try "docker network rm ${nginx_network[*]}" "Failed to remove nginx networks"
    fi

    try "docker volume rm renew-certbot-conf data-certbot-conf dummy-data-certbot-conf" "Failed to remove certbot volumes"

    docker::prune_configs "nginx"
  else
    log error "Valid options are: init, up, down or destroy"
  fi
}

main "$@"
