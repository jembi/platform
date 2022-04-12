#!/bin/bash

cliVersion=0.1.0

curl -L https://github.com/openhie/package-starter-kit/releases/download/$cliVersion/gocli-linux -o platform-linux
curl -L https://github.com/openhie/package-starter-kit/releases/download/$cliVersion/gocli-macos -o platform-macos
curl -L https://github.com/openhie/package-starter-kit/releases/download/$cliVersion/gocli.exe -o platform.exe
chmod +x ./platform-linux
chmod +x ./platform-macos
chmod +x ./platform.exe
