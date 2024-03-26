#!/bin/bash

docker service rm $(docker service ls -q)
docker rm -f $(docker ps -aq)
docker volume prune -af
docker config rm $(docker config ls -q)
docker network prune -f
