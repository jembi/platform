#!/bin/bash
TAG_NAME=${1:-latest}

# We did not specify a tag so try and use the tag in the config.yaml if present
if [ -z "$1" ]; then
    ImageTag=$(docker run --rm -v "${PWD}":/workdir mikefarah/yq:4.24.5 '.image' "config.yaml")
    # only overwrite TAG_NAME if we have a tag present, and it's not just the base image name
    if [[ $ImageTag =~ ":" ]]; then
        TAG_NAME=${ImageTag#*:}
    fi
fi

docker build -t jembi/platform:"$TAG_NAME" .
