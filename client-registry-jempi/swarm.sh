#!/bin/bash

statefulNodes=${STATEFUL_NODES:-"cluster"}

composeFilePath=$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)

if [[ $1 == "init" ]]; then
  docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/importer/docker-compose.config.yml instant

  sleep 60
  # Create topics
  "$composeFilePath"/importer/topics-create.sh
  docker service rm instant_jempi-openhim-config-importer
elif [[ $1 == "up" ]]; then
  docker stack deploy -c "$composeFilePath"/docker-compose.yml instant
elif [[ $1 == "down" ]]; then
  docker service scale instant_zookeeper=0 instant_kafka-1=0 instant_kafka-2=0 instant_kafka-3=0 instant_zero=0 instant_alpha1=0 instant_alpha2=0 instant_alpha3=0 instant_ratel=0 instant_api=0 instant_controller=0 instant_em=0 instant_linker=0 instant_staging-01=0 instant_test-01=0
elif [[ $1 == "destroy" ]]; then
  docker service rm instant_zero instant_zookeeper instant_alpha1 instant_kafka-1 instant_kafka-2 instant_kafka-3 instant_alpha2 instant_alpha3 instant_ratel instant_api instant_controller instant_em instant_linker instant_staging-01 instant_test-01

  echo "Sleep 20 Seconds to allow services to shut down before deleting volumes"
  sleep 20

  docker volume rm instant_zero instant_kafka-1 instant_test-01-csv instant_test-01-csv instant_kafka-2 instant_kafka-3 instant_alpha1 instant_alpha2 instant_alpha3 instant_test-01-logs instant_test-01-csv instant_test-01-conf instant_staging-01-logs instant_staging-01-conf instant_controller-logs instant_controller-conf instant_em-conf instant_em-logs instant_linker-conf instant_linker-logs instant_api-conf instant_api-logs
  docker network rm backend-kafka backend-dgraph frontend-api
else
  echo "Valid options are: init, up, down, or destroy"
fi
