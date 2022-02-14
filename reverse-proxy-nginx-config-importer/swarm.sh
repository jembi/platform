#!/bin/bash

composeFilePath=$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)
domainName=${DOMAIN_NAME:-localhost}
renewalEmail=${RENEWAL_EMAIL}
portsArray=""
timestamp="$(date "+%Y%m%d%H%M%S")"

timestampedNginx="$timestamp-nginx.conf"

if [ "$1" == "init" ] || [ "$1" == "up" ]; then
  if [ "$INSECURE" == "true" ] || [ "$2" == "dev" ]; then
    printf "\nRunning reverse-proxy package in INSECURE mode\n"
    if [ "$INSECURE_PORTS" != "" ]; then
      IFS='-' read -ra PORTS <<<"$INSECURE_PORTS"
      for i in "${PORTS[@]}"; do
        IFS=':' read -ra PORTS_SPLIT <<<"$i"
        if [ "${PORTS_SPLIT[0]}" != "" ] && [ "${PORTS_SPLIT[1]}" != "" ]; then
          portsArray+="--publish-add published=${PORTS_SPLIT[0]},target=${PORTS_SPLIT[1]} "
          printf "\nExposing ports: published=${PORTS_SPLIT[0]},target=${PORTS_SPLIT[1]}\n"
        else
          printf "\nFailed to expose ports: published=${PORTS_SPLIT[0]},target=${PORTS_SPLIT[1]}\n"
        fi
      done
      docker service update \
        $portsArray \
        instant_reverse-proxy-nginx
    fi

    docker config create "$timestampedNginx" "$composeFilePath"/config/nginx-temp-insecure.conf
    docker service update \
      --config-add source="$timestampedNginx", target=/etc/nginx/nginx.conf \
      instant_reverse-proxy-nginx
  else
    printf "\nRunning reverse-proxy package in SECURE mode\n"
    #TODO: Add certificate secret copying for secure mode as part of PLAT-85 work

    echo "Setting up Nginx reverse-proxy with the following domain name: $domainName"

    docker run --rm \
      --network host \
      --name letsencrypt \
      -v "data-certbot-conf:/etc/letsencrypt/archive/$domainName" \
      certbot/certbot certonly -n \
      --staging \
      -m "$renewalEmail" \
      -d "$domainName" \
      --standalone --agree-tos

    docker run --rm --network host --name certbot-helper -w /temp -v data-certbot-conf:/temp-certificates -v instant:/temp busybox sh -c "rm -rf certificates; mkdir certificates; cp -r /temp-certificates/* /temp/certificates"
    docker volume rm data-certbot-conf

    docker secret create "$timestamp-fullchain.pem" "/instant/certificates/fullchain1.pem"
    docker secret create "$timestamp-privkey.pem" "/instant/certificates/privkey1.pem"

    #create copy of nginx-temp-secure.conf to ensure sed will always work correctly
    cp "$composeFilePath"/config/nginx-temp-secure.conf "$composeFilePath"/config/nginx.conf
    sed -i "s/domain_name/$domainName/g;" "$composeFilePath"/config/nginx.conf

    #Update nginx to use the new certificate
    docker config create "$timestampedNginx" "$composeFilePath"/config/nginx.conf
    docker service update \
      --config-add source="$timestampedNginx",target=/etc/nginx/nginx.conf \
      --secret-add source="$timestamp-fullchain.pem",target=/run/secrets/fullchain.pem \
      --secret-add source="$timestamp-privkey.pem",target=/run/secrets/privkey.pem \
      --publish-add published=80,target=80 \
      --publish-add published=443,target=443 \
      instant_reverse-proxy-nginx

    #generate real certificate
    docker run --rm \
      --network host \
      --name letsencrypt \
      -v "data-certbot-conf:/etc/letsencrypt/live/$domainName" \
      certbot/certbot certonly -n \
      --staging \
      -m "$renewalEmail" \
      -d "$domainName" \
      --standalone --agree-tos
    docker run --rm --network host --name certbot-helper -w /temp -v data-certbot-conf:/etc/letsencrypt/live/$domainName -v instant:/temp busybox sh -c "rm -rf certificates; mkdir certificates; cp -r /etc/letsencrypt/live/$domainName/* /temp/certificates"
    docker volume rm data-certbot-conf
  fi
elif [ "$1" == "destroy" ]; then
  # TODO: Remove docker configs as part of PLAT-85 work
  # conf=$(docker config ls --filter "nginx.conf")
  # docker rm $conf
  echo "$1 not implemented yet"
else
  echo "Valid options are: init, up or destroy"
fi
