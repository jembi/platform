#!/bin/bash

# usage: ./remote-img-load.sh <host>

./build-image.sh
echo "Transfering image to $1 ..."
docker save jembi/platform:latest | bzip2 | ssh ubuntu@$1 docker load
echo "Image transfered"
