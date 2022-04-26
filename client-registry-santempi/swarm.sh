#!/bin/bash

statefulNodes=${STATEFUL_NODES:-"cluster"}

composeFilePath=$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)

if [ $statefulNodes == "cluster" ]; then
  printf "\nRunning Client Registry SanteMPI package in Cluster node mode\n"
  postgresClusterComposeParam="-c ${composeFilePath}/docker-compose-postgres.cluster.yml"
else
  printf "\nRunning Client Registry SanteMPI package in Single node mode\n"
  postgresClusterComposeParam=""
fi

if [ "$2" == "dev" ]; then
  printf "\nRunning Client Registry SanteMPI package in DEV mode\n"
  postgresDevComposeParam="-c ${composeFilePath}/docker-compose-postgres.dev.yml"
  santeMPIDevComposeParam="-c ${composeFilePath}/docker-compose.dev.yml"
else
  printf "\nRunning Client Registry SanteMPI package in PROD mode\n"
  postgresDevComposeParam=""
  santeMPIDevComposeParam=""
fi

if [ "$1" == "init" ]; then
  docker stack deploy -c "$composeFilePath"/docker-compose-postgres.yml $postgresClusterComposeParam $postgresDevComposeParam instant

  echo "Sleep 30 seconds to give Postgres time to start up before Sante MPI"
  sleep 30

  docker stack deploy -c "$composeFilePath"/docker-compose.yml $santeMPIDevComposeParam instant
elif [ "$1" == "up" ]; then
  docker stack deploy -c "$composeFilePath"/docker-compose-postgres.yml $postgresClusterComposeParam $postgresDevComposeParam instant

  echo "Sleep 20 seconds to give Postgres time to start up before Sante MPI"
  sleep 20

  docker stack deploy -c "$composeFilePath"/docker-compose.yml $santeMPIDevComposeParam instant
elif [ "$1" == "down" ]; then
  docker service scale instant_santedb-mpi=0 instant_santempi-psql-1=0 instant_santempi-psql-2=0 instant_santempi-psql-3=0
elif [ "$1" == "destroy" ]; then
  docker service rm instant_santedb-www instant_santedb-mpi instant_santempi-psql-1 instant_santempi-psql-2 instant_santempi-psql-3

  echo "Sleep 10 Seconds to allow services to shut down before deleting volumes"
  sleep 10

  docker volume rm instant_santempi-psql-1-data instant_santempi-psql-2-data instant_santempi-psql-3-data

  if [ $statefulNodes == "cluster" ]; then
    echo "Volumes are only deleted on the host on which the command is run. Postgres volumes on other nodes are not deleted"
  fi
else
  echo "Valid options are: init, up, down, or destroy"
fi
