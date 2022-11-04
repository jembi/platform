#!/bin/bash

readonly HOST="$1"
readonly USER=${2:-ubuntu}
if [ -z "${HOST}" ]; then
  echo "Usage: ./remote-img-load.sh <host>"
  exit 1
fi

./build-image.sh
echo "Transfering image to ${HOST} ..."
docker save jembi/platform:latest | bzip2 | ssh "${USER}@${HOST}" docker load
echo "Image transfered"
