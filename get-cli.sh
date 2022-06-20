#!/bin/bash

option="${1:-all}"
cli_version=${2:-0.1.0}

case ${option} in 
   linux)
        echo "Downloading linux binary version: ${cliVersion}"
        curl -L https://github.com/openhie/package-starter-kit/releases/download/$cliVersion/gocli-linux -o platform-linux
        chmod +x ./platform-linux
        exit 0
      ;; 
   macos)
        echo "Downloading macos binary version: ${cliVersion}"
        curl -L https://github.com/openhie/package-starter-kit/releases/download/$cliVersion/gocli-macos -o platform-macos
        chmod +x ./platform-macos
        exit 0
      ;; 
   windows)
        echo "Downloading windows binary version: ${cliVersion}"
        curl -L https://github.com/openhie/package-starter-kit/releases/download/$cliVersion/gocli.exe -o platform.exe
        chmod +x ./platform.exe
        exit 0
      ;;
    all)
        echo "Downloading all binaries, version: ${cliVersion}"
        curl -L https://github.com/openhie/package-starter-kit/releases/download/$cliVersion/gocli-linux -o platform-linux
        curl -L https://github.com/openhie/package-starter-kit/releases/download/$cliVersion/gocli-macos -o platform-macos
        curl -L https://github.com/openhie/package-starter-kit/releases/download/$cliVersion/gocli.exe -o platform.exe
        chmod +x ./platform-linux
        chmod +x ./platform-macos
        chmod +x ./platform.exe
        exit 0
      ;;
    --help)
        echo "Usage: get-cli.sh [linux|macos|windows|all] {cliVersion}"
        exit 0
esac
