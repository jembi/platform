#!/bin/bash

statefulNodes=${STATEFUL_NODES:-"cluster"}

composeFilePath=$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)

if [ $statefulNodes == "cluster" ]; then
  printf "\nRunning FHIR Datastore HAPI FHIR package in Cluster node mode\n"
  postgresClusterComposeParam="-c ${composeFilePath}/docker-compose-postgres.cluster.yml"
else
  printf "\nRunning FHIR Datastore HAPI FHIR package in Single node mode\n"
  postgresClusterComposeParam=""
fi

if [ "$2" == "dev" ]; then
  printf "\nRunning FHIR Datastore HAPI FHIR package in DEV mode\n"
  postgresDevComposeParam="-c ${composeFilePath}/docker-compose-postgres.dev.yml"
  hapiFhirDevComposeParam="-c ${composeFilePath}/docker-compose.dev.yml"
else
  printf "\nRunning FHIR Datastore HAPI FHIR package in PROD mode\n"
  postgresDevComposeParam=""
  hapiFhirDevComposeParam=""
fi

if [ "$1" == "init" ]; then
  docker stack deploy -c "$composeFilePath"/docker-compose-postgres.yml $postgresClusterComposeParam $postgresDevComposeParam instant

  echo "Sleep 60 seconds to give Postgres time to start up before HAPI-FHIR"
  sleep 60

  docker stack deploy -c "$composeFilePath"/docker-compose.yml $hapiFhirDevComposeParam instant
elif [ "$1" == "up" ]; then
  docker stack deploy -c "$composeFilePath"/docker-compose-postgres.yml $postgresClusterComposeParam $postgresDevComposeParam instant

  echo "Sleep 20 seconds to give Postgres time to start up before HAPI-FHIR"
  sleep 20

  docker stack deploy -c "$composeFilePath"/docker-compose.yml $hapiFhirDevComposeParam instant
elif [ "$1" == "down" ]; then
  docker service scale instant_hapi-fhir=0 instant_postgres-1=0 instant_postgres-2=0 instant_postgres-3=0
elif [ "$1" == "destroy" ]; then
  docker service rm instant_hapi-fhir instant_postgres-1 instant_postgres-2 instant_postgres-3

  echo "Sleep 10 Seconds to allow services to shut down before deleting volumes"
  sleep 10

  docker volume rm instant_hapi-postgres-1-data instant_hapi-postgres-2-data instant_hapi-postgres-3-data

  if [ $statefulNodes == "cluster" ]; then
    echo "Volumes are only deleted on the host on which the command is run. Postgres volumes on other nodes are not deleted"
  fi
else
  echo "Valid options are: init, up, down, or destroy"
fi
