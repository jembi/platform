#!/bin/bash

statefulNodes=${STATEFUL_NODES:-"cluster"}

composeFilePath=$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)

function awaitContainerStartup() {
  echo "Waiting for elasticsearch container to start up..."

  local warningTime=60
  local errorTime=300
  local timer=0

  until [[ -n $(docker ps -qlf name=instant_analytics-datastore-elastic-search) ]]; 
  do 
      if [ $timer == $warningTime ]; then
          echo "Warning: container is taking unusually long to start"
      fi;
      if [ $timer == $errorTime ]; then
          echo "Fatal: Elasticsearch container took too long to start up"
          exit 124; # exit code for timeout is 124
      fi;
      sleep 1; 
      timer=$((timer+1))
  done;
  echo "Elasticsearch container started up"
}

function awaitContainerReady() {
  echo "Waiting for elasticsearch container to be in ready state..."

  local warningTime=60
  local errorTime=300
  local timer=0

  until [[ "$(docker inspect -f '{{.State.Status}}' $(docker ps -qlf name=instant_analytics-datastore-elastic-search))" = "running" ]]; 
  do 
      if [ $timer == $warningTime ]; then
          echo "Warning: container is taking unusually long to start"
      fi;
      if [ $timer == $errorTime ]; then
          echo "Fatal: Elasticsearch container took too long to start up"
          exit 124; # exit code for timeout is 124
      fi;
      sleep 1; 
      timer=$((timer+1))
  done;
  echo "Elasticsearch container is in ready state"
}

function installExpect() {
  echo "Installing Expect..."
  # >/dev/null 2>&1 throws all terminal input and output text away
  apt-get install -y expect >/dev/null 2>&1
  if [ $? -eq 1 ]
  then
    echo "Fatal: Failed to install Expect library. Cannot update Elastic Search passwords"
    exit 1
  fi
  echo "Done installing Expect"
}

function setElasticsearchPasswords() {
  echo "Setting passwords..."
  elasticSearchContainerId=$(docker ps -qlf name=instant_analytics-datastore-elastic-search)
  "$composeFilePath"/set-elastic-passwords.exp "$elasticSearchContainerId" >/dev/null 2>&1
  if [ $? -eq 1 ]
  then
    echo "Fatal: Failed to set elastic passwords. Cannot update Elastic Search passwords"
    exit 1
  fi
  echo "Passwords set"
}

function awaitContainerDestroy() {
  echo "Waiting for elasticsearch container to be destroyed"

  local warningTime=60
  local errorTime=300
  local timer=0

  until [[ -z $(docker ps -qlf name=instant_analytics-datastore-elastic-search) ]]; 
  do 
      if [ $timer == $warningTime ]; then
          echo "Warning: container is taking unusually long to be destroyed"
      fi;
      if [ $timer == $errorTime ]; then
          echo "Fatal: Elasticsearch container took too long to be destroyed"
          exit 124; # exit code for timeout is 124
      fi;
      sleep 1; 
      timer=$((timer+1))
  done;
  echo "Elasticsearch container is destroyed"
}

if [ "$statefulNodes" == "cluster" ]; then 
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
  awaitContainerStartup
  awaitContainerReady

  installExpect
  setElasticsearchPasswords
  
  echo "Done initialising"
elif [ "$1" == "up" ]; then
  docker stack deploy -c "$composeFilePath"/docker-compose.yml $elasticSearchClusterComposeParam $elasticSearchDevComposeParam instant
elif [ "$1" == "down" ]; then
  docker service scale instant_analytics-datastore-elastic-search=0
elif [ "$1" == "destroy" ]; then
  docker service rm instant_analytics-datastore-elastic-search

  awaitContainerDestroy
  
  docker volume rm instant_es-data

  if [ "$statefulNodes" == "cluster" ]; then
    echo "Volumes are only deleted on the host on which the command is run. Elastic Search volumes on other nodes are not deleted"
  fi
else
  echo "Valid options are: init, up, down, or destroy"
fi
