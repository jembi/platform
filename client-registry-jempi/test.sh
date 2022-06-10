#!/bin/bash

composeFilePath=$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)

docker create --name csvloader -v instant_test-01-csv:/app/csv busybox
docker cp "$composeFilePath"/importer/csv/. csvloader:/app/csv/
