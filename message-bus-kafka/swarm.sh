#!/bin/bash

statefulNodes=${STATEFUL_NODES:-"cluster"}

composeFilePath=$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)

if [[ $statefulNodes == "cluster" ]]; then
  printf "\nRunning Message Bus Kafka package in Cluster node mode\n"
  kafkaClusterComposeParam="-c ${composeFilePath}/docker-compose.cluster.yml"
else
  printf "\nRunning Message Bus Kafka package in Single node mode\n"
  kafkaClusterComposeParam=""
fi

if [[ $2 == "dev" ]]; then
  printf "\nRunning Message Bus Kafka package in DEV mode\n"
  kafkaDevComposeParam="-c ${composeFilePath}/docker-compose.dev.yml"
else
  printf "\nRunning Message Bus Kafka package in PROD mode\n"
  kafkaDevComposeParam=""
fi

if [[ $1 == "init" ]]; then
  docker stack deploy -c "$composeFilePath"/docker-compose.yml $kafkaClusterComposeParam $kafkaDevComposeParam instant
elif [[ $1 == "up" ]]; then
  docker stack deploy -c "$composeFilePath"/docker-compose.yml $kafkaClusterComposeParam $kafkaDevComposeParam instant
elif [[ $1 == "down" ]]; then
  docker service scale instant_zookeeper-1=0 instant_kafdrop=0
  # You cannot scale a global service so we have to remove it
  docker service rm instant_kafka
  if [[ $statefulNodes == "cluster" ]]; then
    docker service scale instant_zookeeper-2=0
    docker service scale instant_zookeeper-3=0
  fi
elif [[ $1 == "destroy" ]]; then
  docker service rm instant_zookeeper-1 instant_kafka instant_kafdrop

  echo "Sleep 20 Seconds to allow services to shut down before deleting volumes"
  sleep 20

  # TODO remove from all nodes
  docker volume rm instant_kafka-volume
  docker volume rm instant_zookeeper-1-volume

  if [[ $statefulNodes == "cluster" ]]; then
    docker service rm instant_zookeeper-2
    docker service rm instant_zookeeper-3
    echo "Volumes are only deleted on the host on which the command is run. Kafka volumes on other nodes are not deleted"
  fi
else
  echo "Valid options are: init, up, down, or destroy"
fi
