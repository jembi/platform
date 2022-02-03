#!/bin/bash
timestampedName="$(date "+%Y%m%d%H%M%S")nginx.conf"

echo "$timestampedName"
# if [ "$INSECURE_PORTS" != "" ]; then
#     IFS='-' read -ra PORTS <<< "$INSECURE_PORTS"
#     printf "\nExposing ports:\n"
#     for i in "${PORTS[@]}"; do
#         IFS=':' read -ra PORTS_SPLIT <<< "$i"
#         if [ "${PORTS_SPLIT[0]}" != "" ] && [ "${PORTS_SPLIT[1]}" != "" ]; then
#             portsArray+="--publish-add published=${PORTS_SPLIT[0]},target=${PORTS_SPLIT[1]} "
#         fi
#     done
#     echo $portsArray
#     # docker service update \
#     # $portsArray \
#     # instant_reverse-proxy-nginx
# fi
