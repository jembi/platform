#!/bin/bash

readonly HOST="$1"
readonly USER=${2:-ubuntu}
if [ -z "${HOST}" ]; then
  echo "Usage: ./remote-img-load.sh <host>"
  exit 1
fi

TAG_NAME=${1:-latest} #Default to latest if no parameter supplied and no version is specified in the config.yaml file
CONFIG_TAG=$(docker run --rm -v "${PWD}":/workdir mikefarah/yq:4.24.5 '.image' "config.yaml")
if [ "$CONFIG_TAG" != "null" ]; then
  TagVersion=${CONFIG_TAG:15}
  if [ -n "$TagVersion" ]; then
    if [[ -z "$1" ]]; then
      #Override the TAG_NAME with the one specified in config.yaml only if no parameter was supplied
      TAG_NAME=$TagVersion
    fi
  fi
fi

./build-image.sh "$TAG_NAME"
echo "Transfering image to ${HOST} ..."
docker save jembi/platform:$TAG_NAME | bzip2 | ssh "${USER}@${HOST}" docker load
echo "Image transfered"
