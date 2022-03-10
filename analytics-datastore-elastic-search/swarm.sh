#!/bin/bash

statefulNodes=${STATEFUL_NODES:-"cluster"}

composeFilePath=$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)

if [ $statefulNodes == "cluster" ]; then 
  printf "\nRunning Analytics Datastore Elastic Search package in Cluster node mode\n"
  elasticSearchClusterComposeParam="-c ${composeFilePath}/docker-compose.cluster.yml"
else
  printf "\nRunning Analytics Datastore Elastic Search package in Single node mode\n"
  elasticSearchClusterComposeParam=""
fi

if [ "$2" == "dev" ]; then
  printf "\nRunning Analytics Datastore Elastic Search package in DEV mode\n"
  elasticSearchDevComposeParam="-c ${composeFilePath}/docker-compose.dev.yml"
else
  printf "\nRunning Analytics Datastore Elastic Search package in PROD mode\n"
  elasticSearchDevComposeParam=""
fi

if [ "$1" == "init" ]; then
  docker stack deploy -c "$composeFilePath"/docker-compose.yml $elasticSearchClusterComposeParam $elasticSearchDevComposeParam instant

  echo "Waiting for elasticsearch to start before automatically setting built-in passwords..."
  sleep 40
  apt-get install -y expect >/dev/null 2>&1
  echo "Setting passwords..."
  elasticSearchContainerId=$(docker ps -f name=instant_analytics-datastore-elastic-search --format "{{.ID}}")
  "$composeFilePath"/set-pwds.exp $elasticSearchContainerId > /dev/null 2>&1
  echo "Done"
elif [ "$1" == "up" ]; then
  docker stack deploy -c "$composeFilePath"/docker-compose.yml $elasticSearchClusterComposeParam $elasticSearchDevComposeParam instant
elif [ "$1" == "down" ]; then
  docker service scale instant_analytics-datastore-elastic-search=0
elif [ "$1" == "destroy" ]; then
  docker service rm instant_analytics-datastore-elastic-search

  echo "Sleep 20 Seconds to allow services to shut down before deleting volumes"
  sleep 20

  docker volume rm instant_es-data
  # do we need to rm -r the physical data binding /backups/elasticsearch ??

  if [ $statefulNodes == "cluster" ]; then
    echo "Volumes are only deleted on the host on which the command is run. Elastic Search volumes on other nodes are not deleted"
  fi
else
  echo "Valid options are: init, up, down, or destroy"
fi
