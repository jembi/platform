#!/bin/bash

composeFilePath=$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)
domainName=${DOMAIN_NAME:-localhost}
subdomainNames=${SUBDOMAINS:-""}
renewalEmail=${RENEWAL_EMAIL}
portsArray=""
timestamp="$(date "+%Y%m%d%H%M%S")"
staging=${STAGING:-false}
domainArgs=""

if [ ! -z "$subdomainNames" ]; then
  domainArgs="-d $domainName,$subdomainNames"
else
  domainArgs="-d $domainName"
fi

if [ "$staging" == "true" ]; then
  stagingArgs="--staging"
fi

timestampedNginx="$timestamp-nginx.conf"

if [ "$1" == "init" ] || [ "$1" == "up" ]; then
  docker stack deploy -c "$composeFilePath"/docker-compose.yml instant

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

    docker config create --label name=nginx "$timestampedNginx" "$composeFilePath"/config/nginx-temp-insecure.conf
    docker service update \
      --config-add source="$timestampedNginx",target=/etc/nginx/nginx.conf \
      instant_reverse-proxy-nginx
  else
    printf "\nRunning reverse-proxy package in SECURE mode\n"

    echo "Setting up Nginx reverse-proxy with the following domain name: $domainName"
    #Generate dummy certificate
    docker run --rm \
      --network host \
      --name letsencrypt \
      -v "dummy-data-certbot-conf:/etc/letsencrypt/archive/$domainName" \
      certbot/certbot:v1.23.0 certonly -n \
      -m "$renewalEmail" \
      --staging \
      "$domainArgs" \
      --standalone --agree-tos

    docker run --rm --network host --name certbot-helper -w /temp -v dummy-data-certbot-conf:/temp-certificates -v instant:/temp busybox sh -c "rm -rf certificates; mkdir certificates; cp -r /temp-certificates/* /temp/certificates"
    docker volume rm dummy-data-certbot-conf

    docker secret create --label name=nginx "$timestamp-fullchain.pem" "/instant/certificates/fullchain1.pem"
    docker secret create --label name=nginx "$timestamp-privkey.pem" "/instant/certificates/privkey1.pem"

    #Create copy of nginx-temp-secure.conf to ensure sed will always work correctly
    cp "$composeFilePath"/config/nginx-temp-secure.conf "$composeFilePath"/config/nginx.conf
    sed -i "s/domain_name/$domainName/g;" "$composeFilePath"/config/nginx.conf

    nginxNetworkExists=$(docker network ls --filter name=cert-renewal-network --format={{.Name}})
    #Do not create docker network if it exists
    if [ -z "$nginxNetworkExists" ]; then
      docker network create -d overlay --attachable cert-renewal-network
    fi
    
    #Update nginx to use the dummy certificate
    docker config create --label name=nginx "$timestampedNginx" "$composeFilePath"/config/nginx.conf
    docker service update \
      --config-add source="$timestampedNginx",target=/etc/nginx/nginx.conf \
      --secret-add source="$timestamp-fullchain.pem",target=/run/secrets/fullchain.pem \
      --secret-add source="$timestamp-privkey.pem",target=/run/secrets/privkey.pem \
      --network-add name=cert-renewal-network,alias=cert-renewal-network \
      --publish-add published=80,target=80 \
      --publish-add published=443,target=443 \
      instant_reverse-proxy-nginx

    #Generate real certificate
    docker run --rm \
      -p 8083:80 \
      -p 8443:443 \
      --name certbot \
      --network cert-renewal-network \
      -v "data-certbot-conf:/etc/letsencrypt/archive/$domainName" \
      certbot/certbot:v1.23.0 certonly -n \
      --standalone \
      $stagingArgs \
      -m "$renewalEmail" \
      "$domainArgs" \
      --agree-tos 

    timestamp="$(date "+%Y%m%d%H%M%S")"

    docker run --rm --network host --name certbot-helper -w /temp -v data-certbot-conf:/temp-certificates -v instant:/temp busybox sh -c "rm -rf certificates; mkdir certificates; cp -r /temp-certificates/* /temp/certificates"
    docker volume rm data-certbot-conf

    docker secret create --label name=nginx "$timestamp-fullchain.pem" "/instant/certificates/fullchain1.pem"
    docker secret create --label name=nginx "$timestamp-privkey.pem" "/instant/certificates/privkey1.pem"

    currentFullchainName=$(docker service inspect instant_reverse-proxy-nginx --format "{{(index .Spec.TaskTemplate.ContainerSpec.Secrets 0).SecretName}}")
    currentPrivkeyName=$(docker service inspect instant_reverse-proxy-nginx --format "{{(index .Spec.TaskTemplate.ContainerSpec.Secrets 1).SecretName}}")

    docker service update \
      --secret-rm "$currentFullchainName" \
      --secret-rm "$currentPrivkeyName" \
      --secret-add source="$timestamp-fullchain.pem",target=/run/secrets/fullchain.pem \
      --secret-add source="$timestamp-privkey.pem",target=/run/secrets/privkey.pem \
      instant_reverse-proxy-nginx
    
    docker service scale instant_ofelia=1
  fi
elif [ "$1" == "down" ]; then
    docker service scale instant_reverse-proxy-nginx=0
    docker service scale instant_ofelia=0
elif [ "$1" == "destroy" ]; then
  docker service rm instant_reverse-proxy-nginx
  docker service rm instant_ofelia
  nginxSecrets=$(docker secret ls --filter label=name=nginx --format={{.ID}})

  if [ ! -z "$nginxSecrets" ]; then
    docker secret rm $nginxSecrets
  fi

  nginxConfigs=$(docker config ls --filter label=name=nginx --format={{.ID}})

  if [ ! -z "$nginxConfigs" ]; then
    docker config rm $nginxConfigs
  fi

  nginxNetwork=$(docker network ls --filter name=cert-renewal-network --format={{.ID}})

  if [ ! -z "$nginxNetwork" ]; then
      docker network rm $nginxNetwork
  fi
  
  docker volume rm renew-certbot-conf data-certbot-conf dummy-data-certbot-conf 
else
  echo "Valid options are: init, up, down or destroy"
fi
