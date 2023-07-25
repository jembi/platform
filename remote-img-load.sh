#!/bin/bash

readonly HOST="$1"
readonly USER=${2:-ubuntu}
TAG_NAME=${3:-latest} #Default to latest if version is not supplied

if [ -z "${HOST}" ]; then
  echo "Usage: ./remote-img-load.sh <host>"
  exit 1
fi

CONFIG_TAG=$(docker run --rm -v "${PWD}":/workdir mikefarah/yq:4.24.5 '.image' "config.yaml")
if [ "$CONFIG_TAG" != "null" ]; then
  TagVersion=${CONFIG_TAG:15}
  if [ -n "$TagVersion" ]; then
    if [[ -z "$3" ]]; then
      #Override the TAG_NAME with the one specified in config.yaml only if no parameter was supplied
      TAG_NAME=$TagVersion
    fi
  fi
fi
./build-image.sh "$TAG_NAME"
echo "Transfering image to ${HOST} ..."
docker save jembi/platform:"$TAG_NAME" | bzip2 | ssh "${USER}@${HOST}" docker load
echo "Image transfered"
