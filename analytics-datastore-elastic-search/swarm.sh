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
  echo "Waiting for elasticsearch container to start up"
  until [[ ! -z $(docker ps -qlf name=instant_analytics-datastore-elastic-search) ]]; do sleep 0.25; done;
  echo "Waiting for elasticsearch container to be in ready state"
  until [[ "$(docker inspect -f '{{.State.Status}}' $(docker ps -qlf name=instant_analytics-datastore-elastic-search))" = "running" ]]; do sleep 0.25; done

  # >/dev/null 2>&1 throws all terminal input and output text away
  apt-get install -y expect >/dev/null 2>&1
  echo "Setting passwords..."
  elasticSearchContainerId=$(docker ps -qlf name=instant_analytics-datastore-elastic-search)
  "$composeFilePath"/set-elastic-passwords.exp $elasticSearchContainerId >/dev/null 2>&1
  echo "Done"

elif [ "$1" == "up" ]; then
  docker stack deploy -c "$composeFilePath"/docker-compose.yml $elasticSearchClusterComposeParam $elasticSearchDevComposeParam instant
elif [ "$1" == "down" ]; then
  docker service scale instant_analytics-datastore-elastic-search=0
elif [ "$1" == "destroy" ]; then
  docker service rm instant_analytics-datastore-elastic-search

  echo "Waiting for services to shut down before deleting volumes"
  until [[ -z $(docker ps -qlf name=instant_analytics-datastore-elastic-search) ]]; do sleep 0.25; done;

  docker volume rm instant_es-data

  if [ $statefulNodes == "cluster" ]; then
    echo "Volumes are only deleted on the host on which the command is run. Elastic Search volumes on other nodes are not deleted"
  fi
else
  echo "Valid options are: init, up, down, or destroy"
fi
