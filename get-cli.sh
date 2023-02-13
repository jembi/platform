#!/bin/bash

option="${1:-all}"
cli_version=${2:-latest}

case ${option} in
linux)
  echo "Downloading linux binary version: ${cli_version}"
  curl -L https://github.com/openhie/package-starter-kit/releases/download/"$cli_version"/instant-linux -o instant-linux
  chmod +x ./instant-linux
  exit 0
  ;;
macos)
  echo "Downloading macos binary version: ${cli_version}"
  curl -L https://github.com/openhie/package-starter-kit/releases/download/"$cli_version"/instant-macos -o instant-macos
  chmod +x ./instant-macos
  exit 0
  ;;
windows)
  echo "Downloading windows binary version: ${cli_version}"
  curl -L https://github.com/openhie/package-starter-kit/releases/download/"$cli_version"/instant.exe -o instant.exe
  chmod +x ./instant.exe
  exit 0
  ;;
all)
  echo "Downloading all binaries, version: ${cli_version}"
  curl -L https://github.com/openhie/package-starter-kit/releases/download/"$cli_version"/instant-linux -o instant-linux
  curl -L https://github.com/openhie/package-starter-kit/releases/download/"$cli_version"/instant-macos -o instant-macos
  curl -L https://github.com/openhie/package-starter-kit/releases/download/"$cli_version"/instant.exe -o instant.exe
  chmod +x ./instant-linux
  chmod +x ./instant-macos
  chmod +x ./instant.exe
  exit 0
  ;;
--help)
  echo "Usage: get-cli.sh [linux|macos|windows|all] {cli_version}"
  exit 0
  ;;
esac
