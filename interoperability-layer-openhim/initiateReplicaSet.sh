#!/bin/bash

echo 'Initiating the mongo replica set'

mongoCount=${MONGO_SET_COUNT:-3}
config='{"_id":"mongo-set","members":['
priority="1"
for i in $(seq 1 $mongoCount); do
    config=$(printf '%s{"_id":%s,"priority":%s,"host":"mongo-%s:27017"}' $config $(expr $i - 1) $priority $i)
    if [ $i != $mongoCount ]; then
        config=$(printf '%s,' $config)
    fi
    priority="0.5"
done
config=$(printf '%s]}' $config)

echo 'Sleep to ensure all the mongo instances for the replica set are up and running'
runningInstanceCount="0"
startTime=$(date +%s)
warned="false"
while [ $runningInstanceCount != $mongoCount ]; do
    sleep 1

    runningInstanceCount="0"
    for i in $(docker service ls -f name=instant_mongo --format "{{.Replicas}}"); do
        if [ $i = "1/1" ]; then
            runningInstanceCount=$(expr $runningInstanceCount + 1)
        fi
    done

    currentTime=$(date +%s)
    if [ $(expr $currentTime - $startTime) -ge "60" ]; then
        if [ $warned = "false" ]; then
            echo "Warning: Waited 1 minute for mongo set to start. This is taking longer than it should..."
            warned="true"
            startTime=$(date +%s)
        else
            echo "Fatal: Waited 2 minutes for mongo set to start. Exiting..."
            exit 1
        fi
    fi
done
# This sleep ensures that the replica sets are reachable
sleep 10

containerName=""
if [ "$(docker ps -f name=instant_mongo-1 --format "{{.ID}}")" ]; then
    containerName="$(docker ps -f name=instant_mongo-1 --format "{{.ID}}")"
fi

docker exec -i $containerName mongo --eval "rs.initiate($config)"

echo 'Replica set successfully set up'
