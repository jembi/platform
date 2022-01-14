#!/bin/bash

cp -r ../instant/goinstant goinstant-tmp
cp instant-conf/* goinstant-tmp
cd goinstant-tmp
GOOS=darwin GOARCH=amd64 go build -o ../platform-macos
GOOS=linux GOARCH=amd64 go build -o ../platform-linux
GOOS=windows GOARCH=amd64 go build -o ../platform.exe
go clean
cd ..
rm -rf goinstant-tmp
