#!/bin/sh

responseOK="false"
# while [ $responseOK != "true" ]
# do
    # response=$(curl -k --write-out "%{http_code}\n" --silent --output /dev/null https://openhim-core:8080/heartbeat)
    # if [ "$response" = "200" ]; then
    #     responseOK="true"
    # fi
    # sleep 1
# done

echo "await-helper done"
