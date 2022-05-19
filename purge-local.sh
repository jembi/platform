#!/bin/bash

docker service rm $(docker service ls -q)
docker rm -f $(docker ps -aq)
docker volume prune -f
docker config rm $(docker config ls -q)
