#!/bin/bash

statefulNodes=${STATEFUL_NODES:-"cluster"}

composeFilePath=$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)

verifyCore() {
  coreInstances=${OPENHIM_CORE_INSTANCES:-1}
  running="false"
  while [ $running != "true" ]; do
    for i in $(docker service ls -f name=instant_openhim-core --format "{{.Replicas}}"); do
      if [ $i = "$coreInstances/$coreInstances" ]; then
        running="true"
      fi
    done
  done

  complete="false"
  startTime=$(date +%s)
  while [ $complete != "true" ]; do
    sleep 1
    for i in $(docker service ps instant_await-helper --format "{{.CurrentState}}"); do
      if [ $i = "Complete" ]; then
        complete="true"
      elif [ $i = "Failed" ] || [ $i = "Rejected" ]; then
        err=$(docker service ps instant_await-helper --no-trunc --format "{{.Error}}")
        echo "Failed to verify state of openhim-core. Err: $err"
        docker service rm instant_await-helper
        criticalFail
      fi
    done

    currentTime=$(date +%s)
    if [ $(expr $currentTime - $startTime) -ge "300" ]; then
      echo "Waited 5 minutes for openhim-core to start. This is taking longer than it should..."
      startTime=$(date +%s)
    fi
  done

  docker service rm instant_await-helper
}

removeConfigImporter() {
  complete="false"
  startTime=$(date +%s)
  while [ $complete != "true" ]; do
    sleep 1
    for i in $(docker service ps instant_interoperability-layer-openhim-config-importer --format "{{.CurrentState}}"); do
      if [ $i = "Complete" ]; then
        complete="true"
      elif [ $i = "Failed" ] || [ $i = "Rejected" ]; then
        err=$(docker service ps instant_interoperability-layer-openhim-config-importer --no-trunc --format "{{.Error}}")
        echo "Core config importer failed with err: $err"
        docker service rm instant_interoperability-layer-openhim-config-importer
        criticalFail
      fi
    done

    currentTime=$(date +%s)
    if [ $(expr $currentTime - $startTime) -ge "300" ]; then
      echo "Waited 5 minutes for interoperability-layer-openhim-config-importer to run. This is taking longer than it should..."
      startTime=$(date +%s)
    fi
  done

  docker service rm instant_interoperability-layer-openhim-config-importer
}

criticalFail() {
  docker service rm instant_openhim-core instant_openhim-console instant_hapi-proxy instant_mongo-1 instant_mongo-2 instant_mongo-3

  sleep 10
  docker volume rm instant_openhim-mongo1 instant_openhim-mongo2 instant_openhim-mongo3
  docker config rm instant_console.config

  exit 1
}

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
  if [ $? -eq 1 ]; then
    echo "Fatal: Initate Mongo replica set failed."
    exit 1
  fi

  # Set host in OpenHIM console config
  sed -i "s/localhost/$OPENHIM_CORE_MEDIATOR_HOSTNAME/g; s/8080/$OPENHIM_MEDIATOR_API_PORT/g" /instant/interoperability-layer-openhim/importer/volume/default.json

  docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.stack-0.yml $openhimDevComposeParam instant

  docker stack deploy -c "$composeFilePath"/docker-compose.await-helper.yml instant

  echo "Sleeping to give OpenHIM Core time to start up before OpenHIM Console run"
  verifyCore

  docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.stack-1.yml $openhimDevComposeParam instant

  docker stack deploy -c "$composeFilePath"/importer/docker-compose.config.yml instant

  echo "Sleeping to give core config importer time to run before cleaning up service"
  removeConfigImporter

  # Sleep to ensure config importer is removed
  sleep 5
elif [ "$1" == "up" ]; then
  docker stack deploy -c "$composeFilePath"/docker-compose.mongo.yml $mongoClusterComposeParam $mongoDevComposeParam instant
  sleep 20
  docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.stack-1.yml instant
elif [ "$1" == "down" ]; then
  docker service scale instant_openhim-core=0 instant_openhim-console=0 instant_hapi-proxy=0 instant_mongo-1=0 instant_mongo-2=0 instant_mongo-3=0
elif [ "$1" == "destroy" ]; then
  docker service rm instant_openhim-core instant_openhim-console instant_hapi-proxy instant_mongo-1 instant_mongo-2 instant_mongo-3 instant_await-helper

  echo "Sleep 10 Seconds to allow services to shut down before deleting volumes"
  sleep 10

  docker volume rm instant_openhim-mongo1 instant_openhim-mongo2 instant_openhim-mongo3
  docker config rm instant_console.config

  if [ $statefulNodes == "cluster" ]; then
    echo "Volumes are only deleted on the host on which the command is run. Mongo volumes on other nodes are not deleted"
  fi
else
  echo "Valid options are: init, up, down, or destroy"
fi
