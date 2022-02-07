#!/bin/bash

statefulNodes=${STATEFUL_NODES:-"cluster"}

composeFilePath=$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)

if [ $statefulNodes == "cluster" ]; then
  printf "\nRunning Interoperability Layer OpenHIM package in Cluster node mode\n"
  mongoClusterComposeParam="-c ${composeFilePath}/docker-compose-mongo.cluster.yml"
else
  printf "\nRunning Interoperability Layer OpenHIM package in Single node mode\n"
  mongoClusterComposeParam=""
fi

if [ "$2" == "dev" ]; then
  printf "\nRunning Interoperability Layer OpenHIM package in DEV mode\n"
  mongoDevComposeParam="-c ${composeFilePath}/docker-compose-mongo.dev.yml"
  openhimDevComposeParam="-c ${composeFilePath}/docker-compose.dev.yml"
else
  printf "\nRunning Interoperability Layer OpenHIM package in PROD mode\n"
  mongoDevComposeParam=""
  openhimDevComposeParam=""
fi

if [ "$1" == "init" ]; then
  docker stack deploy -c "$composeFilePath"/docker-compose-mongo.yml $mongoClusterComposeParam $mongoDevComposeParam instant

  # Set up the replica set
  "$composeFilePath"/initiateReplicaSet.sh

  docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.stack-0.yml $openhimDevComposeParam instant

  echo "Sleep 60 seconds to give OpenHIM Core time to start up before OpenHIM Console run"
  sleep 60

  docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.stack-1.yml $openhimDevComposeParam instant

  docker stack deploy -c "$composeFilePath"/importer/docker-compose.config.yml instant

  echo "Sleep 60 seconds to give core config importer time to run before cleaning up service"
  sleep 60

  docker service rm instant_core-config-importer
elif [ "$1" == "up" ]; then
  docker stack deploy -c "$composeFilePath"/docker-compose.mongo.yml $mongoClusterComposeParam $mongoDevComposeParam instant
  sleep 20
  docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.stack-1.yml instant
elif [ "$1" == "down" ]; then
  docker service scale instant_openhim-core=0 instant_openhim-console=0 instant_hapi-proxy=0 instant_mongo-1=0 instant_mongo-2=0 instant_mongo-3=0
elif [ "$1" == "destroy" ]; then
  docker service rm instant_openhim-core instant_openhim-console instant_hapi-proxy instant_mongo-1 instant_mongo-2 instant_mongo-3

  echo "Sleep 10 Seconds to allow services to shut down before deleting volumes"
  sleep 10

  docker volume rm instant_openhim-mongo1 instant_openhim-mongo2 instant_openhim-mongo3
  docker config rm instant_console.config
else
  echo "Valid options are: init, up, down, or destroy"
fi
