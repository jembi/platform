#!/bin/bash

composeFilePath=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
domainName=${DOMAIN_NAME:-localhost}
renewalEmail=${RENEWAL_EMAIL}
portsArray=""
timestamp="$(date "+%Y%m%d%H%M%S")"

timestampedNginx="$timestamp-nginx.conf"

if [ "$1" == "init" ] || [ "$1" == "up" ]; then
    if [ "$INSECURE" == "true" ] || [ "$2" == "dev" ]; then
        printf "\nRunning reverse-proxy package in INSECURE mode\n"
        if [ "$INSECURE_PORTS" != "" ]; then
            IFS='-' read -ra PORTS <<< "$INSECURE_PORTS"
            for i in "${PORTS[@]}"; do
                IFS=':' read -ra PORTS_SPLIT <<< "$i"
                if [ "${PORTS_SPLIT[0]}" != "" ] && [ "${PORTS_SPLIT[1]}" != "" ]; then
                    printf "\nExposing ports:\n"
                    portsArray+="--publish-add published=${PORTS_SPLIT[0]},target=${PORTS_SPLIT[1]} "
                fi
            done
            docker service update \
            $portsArray \
            instant_reverse-proxy-nginx
        fi

        docker config create "$timestampedNginx" "$composeFilePath"/config/nginx-temp-insecure.conf
        docker service update \
            --config-add source="$timestampedNginx",target=/etc/nginx/nginx.conf \
            instant_reverse-proxy-nginx
        #TODO: cleanup old docker configs if they become a space hog
    else
        printf "\nRunning reverse-proxy package in SECURE mode\n"
        #TODO: Add certificate secret copying for secure mode as part of PLAT-85 work
        
        # echo "Setting up Nginx reverse-proxy with the following domain name: $domainName"
        # # sleep 5000
        
        # docker run --rm \
        # --network host \
        # -p 443:443 -p 80:80 --name letsencrypt \
        # -v "data-certbot-conf:/etc/letsencrypt/live/$domainName" \
        # -v "data-certbot-conf:/var/lib/letsencrypt/live/$domainName" \
        # certbot/certbot certonly -n \
        # --staging \
        # -m "$renewalEmail" \
        # -d "$domainName" \
        # --standalone --agree-tos

        # docker run --rm --network host --name certbot-helper -w /temp  -v data-certbot-conf:/etc/letsencrypt -v instant:/temp busybox sh -c "mkdir certificates && cp -r /etc/letsencrypt/jembi-mercury.org /temp/certificates"
        # # docker run --network host --name certbot-helper -v data-certbot-conf:/etc/letsencrypt -v instant:/temp --entrypoint "\
        # # 'mkdir' '-p' '/temp/certificates' '&&' 'cp' '-r' '/etc/letsencrypt/jembi-mercury.org' '/temp/certificates'" busybox
        # #check logs of instant
        # docker rm certbot-helper

        # docker secret create "$timestamp-fullchain.pem" "/instant/certificates/fullchain.pem"
        # docker secret create "$timestamp-privkey.pem" "/instant/certificates/privkey.pem"
        # #create copy of nginx-temp-secure.conf to ensure sed will always work correctly
        # cp "$composeFilePath"/config/nginx-temp-secure.conf "$composeFilePath"/config/nginx.conf
        # sed -i "s/domain_name/$domainName/g;" "$composeFilePath"/config/nginx.conf

        # docker config create "$timestampedNginx" "$composeFilePath"/config/nginx.conf
        # docker service update \
        #     --config-add source="$timestampedNginx",target=/etc/nginx/nginx.conf \
        #     --secret-add source="$timestamp-fullchain.pem",target=/run/secrets/fullchain.pem \
        #     --secret-add source="$timestamp-privkey.pem",target=/run/secrets/privkey.pem \
        #     --publish-add published=80,target=80
        #     --publish-add published=443,target=443
        #     instant_reverse-proxy-nginx
    fi
elif [ "$1" == "destroy" ]; then
    # TODO: Remove docker configs as part of PLAT-85 work
    # conf=$(docker config ls --filter "nginx.conf")
    # docker rm $conf
    echo "$1 not implemented yet"
else
    echo "Valid options are: init, up or destroy"
fi
