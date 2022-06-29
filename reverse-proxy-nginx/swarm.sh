#!/bin/bash

# Constants
readonly ACTION=$1
readonly MODE=$2
COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)
readonly COMPOSE_FILE_PATH
readonly DOMAIN_NAME=${DOMAIN_NAME:-localhost}
readonly SUBDOMAINS=${SUBDOMAINS:-""}
readonly RENEWAL_EMAIL=${RENEWAL_EMAIL}
TIMESTAMP="$(date "+%Y%m%d%H%M%S")"
readonly TIMESTAMP
readonly STAGING=${STAGING:-false}
readonly TIMESTAMPED_NGINX="${TIMESTAMP}-nginx.conf"

main() {
  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    if [[ "${MODE}" == "dev" ]]; then
      log info "Not starting reverse proxy as we are running DEV mode"
      exit 0
    fi
    if [[ $(docker service ps instant_reverse-proxy-nginx --format '{{.CurrentState}}') == *"Running"* ]]; then
      log info "Skipping reverse proxy reload as it is already up"
      exit 0
    fi

    docker stack deploy -c "${COMPOSE_FILE_PATH}"/docker-compose.yml instant

    if [[ "${INSECURE}" == "true" ]]; then
      log info "Running reverse-proxy package in INSECURE mode"
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
        if ! docker service update "${portsArray[@]}" instant_reverse-proxy-nginx >/dev/null; then
          log error "Error updating nginx service."
          exit 1
        fi
        log info "Done updating nginx service"
      fi

      docker config create --label name=nginx "${TIMESTAMPED_NGINX}" "${COMPOSE_FILE_PATH}"/config/nginx-temp-insecure.conf

      log info "Updating nginx service: adding config file..."
      if ! docker service update \
        --config-add source="${TIMESTAMPED_NGINX}",target=/etc/nginx/nginx.conf \
        instant_reverse-proxy-nginx \
        >/dev/null; then
        log error "Error updating nginx service"
        exit 1
      fi
      log info "Done updating nginx service"
    else
      log info "Running reverse-proxy package in SECURE mode"

      local domain_args=()
      if [ -n "$SUBDOMAINS" ]; then
        domain_args=(-d "${DOMAIN_NAME},${SUBDOMAINS}")
      else
        domain_args=(-d "${DOMAIN_NAME}")
      fi

      log info "Setting up Nginx reverse-proxy with the following domain name: ${DOMAIN_NAME}"
      #Generate dummy certificate
      docker run --rm \
        --network host \
        --name letsencrypt \
        -v "dummy-data-certbot-conf:/etc/letsencrypt/archive/${DOMAIN_NAME}" \
        certbot/certbot:v1.23.0 certonly -n \
        -m "${RENEWAL_EMAIL}" \
        --staging \
        "${domain_args[@]}" \
        --standalone --agree-tos

      docker run --rm --network host --name certbot-helper -w /temp \
        -v dummy-data-certbot-conf:/temp-certificates \
        -v instant:/temp busybox sh \
        -c "rm -rf certificates; mkdir certificates; cp -r /temp-certificates/* /temp/certificates"
      docker volume rm dummy-data-certbot-conf

      docker secret create --label name=nginx "${TIMESTAMP}-fullchain.pem" "/instant/certificates/fullchain1.pem"
      docker secret create --label name=nginx "${TIMESTAMP}-privkey.pem" "/instant/certificates/privkey1.pem"

      #Create copy of nginx-temp-secure.conf to ensure sed will always work correctly
      cp "${COMPOSE_FILE_PATH}"/config/nginx-temp-secure.conf "${COMPOSE_FILE_PATH}"/config/nginx.conf
      sed -i "s/domain_name/${DOMAIN_NAME}/g;" "${COMPOSE_FILE_PATH}"/config/nginx.conf

      local nginx_network_exists
      nginx_network_exists=$(docker network ls --filter name=cert-renewal-network --format '{{.Name}}')
      #Do not create docker network if it exists
      if [[ -z "${nginx_network_exists}" ]]; then
        docker network create -d overlay --attachable cert-renewal-network
      fi

      #Update nginx to use the dummy certificate
      docker config create --label name=nginx "${TIMESTAMPED_NGINX}" "${COMPOSE_FILE_PATH}"/config/nginx.conf

      log info "Updating nginx service: adding config for dummy certificates..."
      if ! docker service update \
        --config-add source="${TIMESTAMPED_NGINX}",target=/etc/nginx/nginx.conf \
        --secret-add source="${TIMESTAMP}-fullchain.pem",target=/run/secrets/fullchain.pem \
        --secret-add source="${TIMESTAMP}-privkey.pem",target=/run/secrets/privkey.pem \
        --network-add name=cert-renewal-network,alias=cert-renewal-network \
        --publish-add published=80,target=80 \
        --publish-add published=443,target=443 \
        instant_reverse-proxy-nginx >/dev/null; then
        log error "Error updating nginx service"
        exit 1
      fi
      log info "Done updating nginx service"

      if [ "${STAGING}" == "true" ]; then
        local staging_args="--staging"
      fi

      #Generate real certificate
      docker run --rm \
        -p 8083:80 \
        -p 8443:443 \
        --name certbot \
        --network cert-renewal-network \
        -v "data-certbot-conf:/etc/letsencrypt/archive/${DOMAIN_NAME}" \
        certbot/certbot:v1.23.0 certonly -n \
        --standalone \
        ${staging_args} \
        -m "${RENEWAL_EMAIL}" \
        "${domain_args[@]}" \
        --agree-tos

      docker run --rm --network host --name certbot-helper -w /temp \
        -v data-certbot-conf:/temp-certificates \
        -v instant:/temp busybox sh \
        -c "rm -rf certificates; mkdir certificates; cp -r /temp-certificates/* /temp/certificates"
      docker volume rm data-certbot-conf

      local new_timestamp
      new_timestamp="$(date "+%Y%m%d%H%M%S")"
      docker secret create --label name=nginx "${new_timestamp}-fullchain.pem" "/instant/certificates/fullchain1.pem"
      docker secret create --label name=nginx "${new_timestamp}-privkey.pem" "/instant/certificates/privkey1.pem"

      local curr_full_chain_name
      curr_full_chain_name=$(docker service inspect instant_reverse-proxy-nginx --format "{{(index .Spec.TaskTemplate.ContainerSpec.Secrets 0).SecretName}}")
      local curr_priv_key_name
      curr_priv_key_name=$(docker service inspect instant_reverse-proxy-nginx --format "{{(index .Spec.TaskTemplate.ContainerSpec.Secrets 1).SecretName}}")

      log info "Updating nginx service: adding secrets for generated certificates"
      if ! docker service update \
        --secret-rm "${curr_full_chain_name}" \
        --secret-rm "${curr_priv_key_name}" \
        --secret-add source="${new_timestamp}-fullchain.pem",target=/run/secrets/fullchain.pem \
        --secret-add source="${new_timestamp}-privkey.pem",target=/run/secrets/privkey.pem \
        instant_reverse-proxy-nginx >/dev/null; then
        log error "Error updating nginx service"
        exit 1
      fi
      log info "Done updating nginx service"

      log info "Scaling up ofelia service..."
      if ! docker service scale instant_ofelia=1 >/dev/null; then
        log error "Error scaling up ofelia service"
        exit 1
      fi
      log info "Done scaling up ofelia service"
    fi
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down services..."
    if ! docker service scale instant_reverse-proxy-nginx=0 instant_ofelia=0 >/dev/null; then
      log error "Error scaling down services"
      exit 1
    fi
    log info "Done scaling down services"
  elif [[ "${ACTION}" == "destroy" ]]; then
    docker service rm instant_reverse-proxy-nginx
    docker service rm instant_ofelia

    mapfile -t nginx_secrets < <(docker secret ls -qf label=name=nginx)
    if [[ "${#nginx_secrets[@]}" -ne 0 ]]; then
      docker secret rm "${nginx_secrets[@]}"
    fi

    mapfile -t nginx_configs < <(docker config ls -qf label=name=nginx)
    if [[ "${#nginx_configs[@]}" -ne 0 ]]; then
      docker config rm "${nginx_configs[@]}"
    fi

    mapfile -t nginx_network < <(docker network ls -qf name=cert-renewal-network)
    if [[ "${#nginx_network}" -ne 0 ]]; then
      docker network rm "${nginx_network[@]}"
    fi

    docker volume rm renew-certbot-conf data-certbot-conf dummy-data-certbot-conf
  else
    log error "Valid options are: init, up, down or destroy"
  fi
}

main "$@"
