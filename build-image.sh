#!/bin/bash

docker build --target base -t instant-base:latest ../instant
docker build -t jembi/platform:latest .
