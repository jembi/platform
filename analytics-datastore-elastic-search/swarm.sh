#!/bin/bash

Action=$1
Mode=$2

STATEFUL_NODES=${STATEFUL_NODES:-"cluster"}

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)

AwaitContainerStartup() {
  echo "Waiting for elasticsearch container to start up..."

  local warningTime=60
  local errorTime=300
  local timer=0

  until [[ -n $(docker ps -qlf name=instant_analytics-datastore-elastic-search) ]]; do
    if [[ "$timer" == "$warningTime" ]]; then
      echo "Warning: container is taking unusually long to start"
    fi
    if [[ "$timer" == "$errorTime" ]]; then
      echo "Fatal: Elasticsearch container took too long to start up"
      exit 124 # exit code for timeout is 124
    fi
    sleep 1
    timer=$((timer + 1))
  done
  echo "Elasticsearch container started up"
}

AwaitContainerReady() {
  echo "Waiting for elasticsearch container to be in ready state..."

  local warningTime=60
  local errorTime=300
  local timer=0

  until [[ "$(docker inspect -f '{{.State.Status}}' $(docker ps -qlf name=instant_analytics-datastore-elastic-search))" = "running" ]]; do
    if [[ "$timer" == "$warningTime" ]]; then
      echo "Warning: container is taking unusually long to start"
    fi
    if [[ "$timer" == "$errorTime" ]]; then
      echo "Fatal: Elasticsearch container took too long to start up"
      exit 124 # exit code for timeout is 124
    fi
    sleep 1
    timer=$((timer + 1))
  done
  echo "Elasticsearch container is in ready state"
}

InstallExpect() {
  echo "Installing Expect..."
  # >/dev/null 2>&1 throws all terminal input and output text away
  apt-get install -y expect >/dev/null 2>&1
  if [[ $? -eq 1 ]]; then
    echo "Fatal: Failed to install Expect library. Cannot update Elastic Search passwords"
    exit 1
  fi
  echo "Done installing Expect"
}

SetElasticsearchPasswords() {
  echo "Setting passwords..."
  local elasticSearchContainerId=""
  elasticSearchContainerId=$(docker ps -qlf name=instant_analytics-datastore-elastic-search)
  "$COMPOSE_FILE_PATH"/set-elastic-passwords.exp "$elasticSearchContainerId" >/dev/null 2>&1
  if [[ $? -eq 1 ]]; then
    echo "Fatal: Failed to set elastic passwords. Cannot update Elastic Search passwords"
    exit 1
  fi
  echo "Passwords set"
}

AwaitContainerDestroy() {
  echo "Waiting for elasticsearch container to be destroyed"

  local warningTime=60
  local errorTime=300
  local timer=0

  until [[ -z $(docker ps -qlf name=instant_analytics-datastore-elastic-search) ]]; do
    if [[ "$timer" == "$warningTime" ]]; then
      echo "Warning: container is taking unusually long to be destroyed"
    fi
    if [[ "$timer" == "$errorTime" ]]; then
      echo "Fatal: Elasticsearch container took too long to be destroyed"
      exit 124 # exit code for timeout is 124
    fi
    sleep 1
    timer=$((timer + 1))
  done
  echo "Elasticsearch container is destroyed"
}

if [[ "$STATEFUL_NODES" == "cluster" ]]; then
  printf "\nRunning Analytics Datastore Elastic Search package in Cluster node mode\n"
  ElasticSearchClusterComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.cluster.yml"
else
  printf "\nRunning Analytics Datastore Elastic Search package in Single node mode\n"
  ElasticSearchClusterComposeParam=""
fi

if [[ "$Mode" == "dev" ]]; then
  printf "\nRunning Analytics Datastore Elastic Search package in DEV mode\n"
  ElasticSearchDevComposeParam="-c ${COMPOSE_FILE_PATH}/docker-compose.dev.yml"
else
  printf "\nRunning Analytics Datastore Elastic Search package in PROD mode\n"
  ElasticSearchDevComposeParam=""
fi

if [[ "$Action" == "init" ]]; then
  docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $ElasticSearchClusterComposeParam $ElasticSearchDevComposeParam instant

  echo "Waiting for elasticsearch to start before automatically setting built-in passwords..."
  AwaitContainerStartup
  AwaitContainerReady

  InstallExpect
  SetElasticsearchPasswords

  echo "Done initialising"
elif [[ "$Action" == "up" ]]; then
  docker stack deploy -c "$COMPOSE_FILE_PATH"/docker-compose.yml $ElasticSearchClusterComposeParam $ElasticSearchDevComposeParam instant
elif [[ "$Action" == "down" ]]; then
  docker service scale instant_analytics-datastore-elastic-search=0
elif [[ "$Action" == "destroy" ]]; then
  docker service rm instant_analytics-datastore-elastic-search

  AwaitContainerDestroy

  docker volume rm instant_es-data

  if [[ "$STATEFUL_NODES" == "cluster" ]]; then
    echo "Volumes are only deleted on the host on which the command is run. Elastic Search volumes on other nodes are not deleted"
  fi
else
  echo "Valid options are: init, up, down, or destroy"
fi
