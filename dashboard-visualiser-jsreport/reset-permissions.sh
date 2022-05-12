#!/usr/bin/env bash

apk update; apk add docker

until [[ $(docker ps -f name=instant_dashboard-visualiser-jsreport --format "{{.Status}}") != *"Up"* ]]; do
    sleep 1
done

if ! chown -R 1000 ./JSR/; then
    echo "Could not reset user id"
fi
if ! chgrp -R 1000 ./JSR/; then
    echo "Could not reset group id"
fi
