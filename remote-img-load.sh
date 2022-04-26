#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: ./remote-img-load.sh <host>"
  exit 1
fi

./build-image.sh
echo "Transfering image to $1 ..."
docker save jembi/platform:latest | bzip2 | ssh ubuntu@$1 docker load
echo "Image transfered"
