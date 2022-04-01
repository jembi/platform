#!/bin/bash

STATEFUL_NODES=${STATEFUL_NODES:-"cluster"}
OPENHIM_CORE_MEDIATOR_HOSTNAME=${OPENHIM_CORE_MEDIATOR_HOSTNAME:-"localhost"}
OPENHIM_MEDIATOR_API_PORT=${OPENHIM_MEDIATOR_API_PORT:-"8080"}
OPENHIM_CORE_INSTANCES=${OPENHIM_CORE_INSTANCES:-1}
MONGO_SET_COUNT=${MONGO_SET_COUNT:-3}

ComposeFilePath=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)

VerifyCore() {
  local startTime=$(date +%s)
  until [[ $(docker service ls -f name=instant_openhim-core --format "{{.Replicas}}") == *"$OPENHIM_CORE_INSTANCES/$OPENHIM_CORE_INSTANCES"* ]]; do
    TimeoutCheck $startTime "openhim-core to start"
    sleep 1
  done

  local awaitHelperState=$(docker service ps instant_await-helper --format "{{.CurrentState}}")
  until [[ $awaitHelperState == *"Complete"* ]]; do
    TimeoutCheck $startTime "openhim-core heartbeat check"
    sleep 1

    awaitHelperState=$(docker service ps instant_await-helper --format "{{.CurrentState}}")
    if [[ $awaitHelperState == *"Failed"* ]] || [[ $awaitHelperState == *"Rejected"* ]]; then
      err=$(docker service ps instant_await-helper --no-trunc --format "{{.Error}}")
      echo "Fatal: Received error when trying to verify state of openhim-core. Error: $err"
      exit 1
    fi
  done

  docker service rm instant_await-helper
}

RemoveConfigImporter() {
  local complete="false"
  local startTime=$(date +%s)
  local configImporterState=$(docker service ps instant_interoperability-layer-openhim-config-importer --format "{{.CurrentState}}")
  until [[ $configImporterState == *"Complete"* ]]; do
    TimeoutCheck $startTime "interoperability-layer-openhim-config-importer to run"
    sleep 1

    configImporterState=$(docker service ps instant_interoperability-layer-openhim-config-importer --format "{{.CurrentState}}")
    if [[ $configImporterState == *"Failed"* ]] || [[ $configImporterState == *"Rejected"* ]]; then
      err=$(docker service ps instant_interoperability-layer-openhim-config-importer --no-trunc --format "{{.Error}}")
      echo "Fatal: Core config importer failed with error: $err"
      exit 1
    fi
  done

  docker service rm instant_interoperability-layer-openhim-config-importer
}

TimeoutCheck() {
  local startTime=$(($1))
  local message=$2
  local timeDiff=$(($(date +%s) - $startTime))
  if [[ $timeDiff -ge 60 ]] && [[ $timeDiff -lt 61 ]]; then
    echo "Warning: Waited 1 minute for $message. This is taking longer than it should..."
  elif [[ $timeDiff -ge 120 ]]; then
    echo "Fatal: Waited 2 minutes for $message. Exiting..."
    exit 1
  fi
}

VerifyMongos() {
  echo 'Waiting to ensure all the mongo instances for the replica set are up and running'
  local runningInstanceCount=0
  local startTime=$(date +%s)
  until [[ $runningInstanceCount -eq $MONGO_SET_COUNT ]]; do
    TimeoutCheck $startTime "mongo set to start"
    sleep 1

    runningInstanceCount=0
    for i in $(docker service ls -f name=instant_mongo --format "{{.Replicas}}"); do
      if [[ $i = "1/1" ]]; then
        runningInstanceCount=$(($runningInstanceCount + 1))
      fi
    done
  done
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

  echo "Waiting to give OpenHIM Core time to start up before OpenHIM Console run"
  VerifyCore

  docker stack deploy -c "$ComposeFilePath"/docker-compose.yml -c "$ComposeFilePath"/docker-compose.stack-1.yml $OpenhimDevComposeParam instant

  docker stack deploy -c "$ComposeFilePath"/importer/docker-compose.config.yml instant

  echo "Waiting to give core config importer time to run before cleaning up service"
  RemoveConfigImporter

  # Sleep to ensure config importer is removed
  sleep 5
elif [[ "$1" == "up" ]]; then
  docker stack deploy -c "$ComposeFilePath"/docker-compose-mongo.yml $MongoClusterComposeParam $MongoDevComposeParam instant
  VerifyMongos
  docker stack deploy -c "$ComposeFilePath"/docker-compose.yml -c "$ComposeFilePath"/docker-compose.stack-1.yml $OpenhimDevComposeParam instant
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
