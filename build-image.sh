#!/bin/bash
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
docker build -t jembi/platform:"$TAG_NAME" .
