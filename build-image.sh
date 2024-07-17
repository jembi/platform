#!/bin/bash
TAG_NAME=${1:-latest}

# We did not specify a tag so try and use the tag in the config.yaml if present
if [ -z "$1" ]; then
    # we grep out 'image: jembi/platform:2.x' from which we cut on : and choose the last column
    # this will always be the image tag or an empty string
    ImageTag=$(grep 'image:' ${PWD}/config.yaml | cut -d : -f 3)
    # only overwrite TAG_NAME if we have a tag present, and it's not just the base image name
    if [ -n "$ImageTag" ]; then
        TAG_NAME=${ImageTag}
    fi
fi

docker build -t jembi/platform:"$TAG_NAME" .
