#!/bin/bash

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)
# COMPOSE_FILE_PATH="/home/markl/Documents/Projects/platform/dashboard-visualiser-jsreport"

"$COMPOSE_FILE_PATH"/swarm -action="$1" -mode="$2" -path="$COMPOSE_FILE_PATH"
# GOOS=linux GOARCH=amd64 go build -o swarm
# "$COMPOSE_FILE_PATH"/swarm -action="init" -mode="dev" -path="$COMPOSE_FILE_PATH"
