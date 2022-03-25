#!/bin/bash

STATEFUL_NODES=${STATEFUL_NODES:-"cluster"}
OPENHIM_CORE_MEDIATOR_HOSTNAME=${OPENHIM_CORE_MEDIATOR_HOSTNAME:-"localhost"}
OPENHIM_MEDIATOR_API_PORT=${OPENHIM_MEDIATOR_API_PORT:-"8080"}
OPENHIM_CORE_INSTANCES=${OPENHIM_CORE_INSTANCES:-1}
Warned="false"

ComposeFilePath=$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)

VerifyCore() {
  local running="false"
  local startTime
  startTime=$(date +%s)
  Warned="false"
  while [[ $running != "true" ]]; do
    TimeoutCheck $startTime $Warned "openhim-core to start"
    sleep 1

    if [[ $(docker service ls -f name=instant_openhim-core --format "{{.Replicas}}") == *"$OPENHIM_CORE_INSTANCES/$OPENHIM_CORE_INSTANCES"* ]]; then
      running="true"
    fi
  done

  local complete="false"
  Warned="false"
  while [[ $complete != "true" ]]; do
    TimeoutCheck $startTime $Warned "openhim-core heartbeat check"
    sleep 1

    local awaitHelperState=$(docker service ps instant_await-helper --format "{{.CurrentState}}")
    if [[ $awaitHelperState == *"Complete"* ]]; then
      complete="true"
    elif [[ $awaitHelperState == *"Failed"* ]] || [ $awaitHelperState == *"Rejected"* ]]; then
      err=$(docker service ps instant_await-helper --no-trunc --format "{{.Error}}")
      echo "Fatal: Received error when trying to verify state of openhim-core. Error: $err"
      exit 1
    fi
  done

  docker service rm instant_await-helper
}

RemoveConfigImporter() {
  local complete="false"
  local startTime
  startTime=$(date +%s)
  Warned="false"
  while [[ $complete != "true" ]]; do
    TimeoutCheck $startTime $Warned "interoperability-layer-openhim-config-importer to run"
    sleep 1

    local configImporterState=$(docker service ps instant_interoperability-layer-openhim-config-importer --format "{{.CurrentState}}")
    if [[ $configImporterState == *"Complete"* ]]; then
      complete="true"
    elif [[ $configImporterState == *"Failed"* ]] || [[ $configImporterState == *"Rejected"* ]]; then
      err=$(docker service ps instant_interoperability-layer-openhim-config-importer --no-trunc --format "{{.Error}}")
      echo "Fatal: Core config importer failed with error: $err"
      exit 1
    fi
  done

  docker service rm instant_interoperability-layer-openhim-config-importer
}

TimeoutCheck() {
  local startTime=$(($1))
  Warned=$2
  local message=$3
  local currentTime
  currentTime=$(date +%s)
  if [[ $(($currentTime - $startTime)) -ge 60 ]] && [[ $Warned == "false" ]]; then
    echo "Warning: Waited 1m minute for $message. This is taking longer than it should..."
    Warned="true"
  elif [[ $(($currentTime - $startTime)) -ge 120 ]] && [[ $Warned == "true" ]]; then
    echo "Fatal: Waited 2m minutes for $message. Exiting..."
    exit 1
  fi
}

if [[ $STATEFUL_NODES == "cluster" ]]; then
  printf "\nRunning Interoperability Layer OpenHIM package in Cluster node mode\n"
  MongoClusterComposeParam="-c ${ComposeFilePath}/docker-compose-mongo.cluster.yml"
else
  printf "\nRunning Interoperability Layer OpenHIM package in Single node mode\n"
  MongoClusterComposeParam=""
fi

if [[ "$2" == "dev" ]]; then
  printf "\nRunning Interoperability Layer OpenHIM package in DEV mode\n"
  MongoDevComposeParam="-c ${ComposeFilePath}/docker-compose-mongo.dev.yml"
  OpenhimDevComposeParam="-c ${ComposeFilePath}/docker-compose.dev.yml"
else
  printf "\nRunning Interoperability Layer OpenHIM package in PROD mode\n"
  MongoDevComposeParam=""
  OpenhimDevComposeParam=""
fi

if [[ "$1" == "init" ]]; then
  docker stack deploy -c "$ComposeFilePath"/docker-compose-mongo.yml $MongoClusterComposeParam $MongoDevComposeParam instant

  # Set up the replica set
  "$ComposeFilePath"/initiateReplicaSet.sh
  if [[ $? -eq 1 ]]; then
    echo "Fatal: Initate Mongo replica set failed."
    exit 1
  fi

  # Set host in OpenHIM console config
  sed -i "s/localhost/$OPENHIM_CORE_MEDIATOR_HOSTNAME/g; s/8080/$OPENHIM_MEDIATOR_API_PORT/g" /instant/interoperability-layer-openhim/importer/volume/default.json

  docker stack deploy -c "$ComposeFilePath"/docker-compose.yml -c "$ComposeFilePath"/docker-compose.stack-0.yml $OpenhimDevComposeParam instant

  docker stack deploy -c "$ComposeFilePath"/docker-compose.await-helper.yml instant

  echo "Sleeping to give OpenHIM Core time to start up before OpenHIM Console run"
  VerifyCore

  docker stack deploy -c "$ComposeFilePath"/docker-compose.yml -c "$ComposeFilePath"/docker-compose.stack-1.yml $OpenhimDevComposeParam instant

  docker stack deploy -c "$ComposeFilePath"/importer/docker-compose.config.yml instant

  echo "Sleeping to give core config importer time to run before cleaning up service"
  RemoveConfigImporter

  # Sleep to ensure config importer is removed
  sleep 5
elif [[ "$1" == "up" ]]; then
  docker stack deploy -c "$ComposeFilePath"/docker-compose-mongo.yml $MongoClusterComposeParam $MongoDevComposeParam instant
  sleep 20
  docker stack deploy -c "$ComposeFilePath"/docker-compose.yml -c "$ComposeFilePath"/docker-compose.stack-1.yml instant
elif [[ "$1" == "down" ]]; then
  docker service scale instant_openhim-core=0 instant_openhim-console=0 instant_mongo-1=0 instant_mongo-2=0 instant_mongo-3=0
elif [[ "$1" == "destroy" ]]; then
  docker service rm instant_openhim-core instant_openhim-console instant_mongo-1 instant_mongo-2 instant_mongo-3 instant_await-helper
  docker service rm instant_interoperability-layer-openhim-config-importer

  echo "Sleep 10 Seconds to allow services to shut down before deleting volumes"
  sleep 10

  docker volume rm instant_openhim-mongo1 instant_openhim-mongo2 instant_openhim-mongo3
  docker config rm instant_console.config

  if [[ $STATEFUL_NODES == "cluster" ]]; then
    echo "Volumes are only deleted on the host on which the command is run. Mongo volumes on other nodes are not deleted"
  fi
else
  echo "Valid options are: init, up, down, or destroy"
fi
