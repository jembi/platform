#!/bin/bash

cp -r ../instant/goinstant goinstant-run-tmp
cp instant-conf/* goinstant-run-tmp

cd goinstant-run-tmp
GOOS=linux GOARCH=amd64 go run . "$@"
cd ..
