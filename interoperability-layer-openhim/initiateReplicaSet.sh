#!/bin/bash

echo 'Initiating the mongo replica set'

COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
)

ROOT_PATH="${COMPOSE_FILE_PATH}/.."
. "${ROOT_PATH}/utils/config-utils.sh"

MONGO_SET_COUNT=${MONGO_SET_COUNT:-3}
Config='{"_id":"mongo-set","members":['
Priority="1"
for i in $(seq 1 $MONGO_SET_COUNT); do
    Config=$(printf '%s{"_id":%s,"priority":%s,"host":"mongo-%s:27017"}' $Config $(($i - 1)) $Priority $i)
    if [[ $i != $MONGO_SET_COUNT ]]; then
        Config=$(printf '%s,' $Config)
    fi
    Priority="0.5"
done
Config=$(printf '%s]}' "$Config")

echo 'Waiting to ensure all the mongo instances for the replica set are up and running'
RunningInstanceCount=0
StartTime=$(date +%s)
until [[ $RunningInstanceCount -eq $MONGO_SET_COUNT ]]; do
    config::timeout_check $StartTime "mongo replica set to run" "60" "300"
    sleep 1

    RunningInstanceCount=0
    for i in $(docker service ls -f name=instant_mongo --format "{{.Replicas}}"); do
        if [[ $i = "1/1" ]]; then
            RunningInstanceCount=$(($RunningInstanceCount + 1))
        fi
    done
done
# This sleep ensures that the replica sets are reachable
sleep 10

ContainerName=""
if [[ "$(docker ps -f name=instant_mongo-1 --format "{{.ID}}")" ]]; then
    ContainerName="$(docker ps -f name=instant_mongo-1 --format "{{.ID}}")"
fi

InitiateRepSetResponse=$(docker exec -i "$ContainerName" mongo --eval "rs.initiate($Config)")
if [[ $InitiateRepSetResponse == *"{ \"ok\" : 1 }"* ]] || [[ $InitiateRepSetResponse == *"already initialized"* ]]; then
    echo "Replica set successfully set up"
else
    echo "Fatal: Unable to set up replica set"
    exit 1
fi
