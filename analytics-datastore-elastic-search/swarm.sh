#!/bin/bash

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)

GOOS=linux GOARCH=amd64 go build -o swarm
"$COMPOSE_FILE_PATH"/swarm -action="$1" -mode="$2" -path="$COMPOSE_FILE_PATH" -statefulNodes="${STATEFUL_NODES:-"cluster"}"
