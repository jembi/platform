#!/bin/bash

composeFilePath=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

if [ "$1" == "init" ]; then
  apt-get install -y expect >/dev/null 2>&1
  
  if  [ "$2" == "dev" ]; then
    docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.dev.yml -c "$composeFilePath"/docker-compose.stack-0.yml instant

    echo "Waiting for elasticsearch to start before automatically setting built-in passwords..."
    sleep 40
    echo "Setting passwords..."
    "$composeFilePath"/set-pwds-swarm.exp
    echo "Done"

    echo "Setting passwords in config files..."
    sed -i "s/dev_password_only/$ES_ELASTIC/g" "$composeFilePath"/../../elastic-pipeline/pipeline/*.conf
    sed -i "s/dev_password_only/$ES_ELASTIC/g" "$composeFilePath"/../../elastic-pipeline/logstash.yml
    echo "Done"

    docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.dev.yml -c "$composeFilePath"/docker-compose.stack-1.yml instant
  else
    docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.prod.yml -c "$composeFilePath"/docker-compose.stack-0.yml instant

    echo "Waiting for elasticsearch to start before automatically setting built-in passwords..."
    sleep 40
    echo "Setting passwords..."
    "$composeFilePath"/set-pwds-swarm.exp
    echo "Done"

    echo "Setting passwords in config files..."
    sed -i "s/dev_password_only/$ES_ELASTIC/g" "$composeFilePath"/../../elastic-pipeline/pipeline/*.conf
    sed -i "s/dev_password_only/$ES_ELASTIC/g" "$composeFilePath"/../../elastic-pipeline/logstash.yml
    echo "Done"

    docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.prod.yml -c "$composeFilePath"/docker-compose.stack-1.yml instant
  fi
elif [ "$1" == "up" ]; then
  if  [ "$2" == "dev" ]; then
    docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.dev.yml -c "$composeFilePath"/docker-compose.stack-1.yml instant
  else
    docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.prod.yml -c "$composeFilePath"/docker-compose.stack-1.yml instant
  fi
elif [ "$1" == "down" ]; then
    docker service scale instant_es-analytics=0 instant_kibana=0
elif [ "$1" == "destroy" ]; then
    docker service rm instant_es-analytics instant_kibana
    sleep 15
    docker volume rm instant_es-data
else
    echo "Valid options are: init, up, down, or destroy"
fi
