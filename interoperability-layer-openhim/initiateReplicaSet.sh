#!/bin/sh

set -eu

echo 'Initiating the mongo replica set'

config='{"_id":"mongo-set","members":[{"_id":0,"priority":1,"host":"mongo-1:27017"},
{"_id":1,"priority":0.5,"host":"mongo-2:27017"},{"_id":2,"priority":0.5,"host":"mongo-3:27017"}]}'

echo '\nSleep to ensure all the mongo instances for the replica set are up and running'
runningInstanceCount="0"
while [ $runningInstanceCount != "3" ]
do
    runningInstanceCount="0"
    for i in $(docker service ls -f name=instant_mongo)
    do
        if [ $i = "1/1" ]; then
            runningInstanceCount=`expr $runningInstanceCount + 1`   
        fi
    done
done
# This sleep ensures that the replica sets are reachable
sleep 5

containerName='mongo-1'

if [ "$(docker ps -f name=instant_mongo-1 --format "{{.ID}}")" ]; then
  containerName="$(docker ps -f name=instant_mongo-1 --format "{{.ID}}")"
fi

docker exec -i $containerName mongo --eval "rs.initiate($config)"

sleep 30

echo 'Replica set successfully set up'
