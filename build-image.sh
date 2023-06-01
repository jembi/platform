#!/bin/bash
TAG_NAME=${1:-latest}
docker build -t jembi/platform:"$TAG_NAME" .
