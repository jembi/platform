#!/bin/bash

option="${1:-all}"
cli_version=${2:-latest}

case ${option} in
linux)
  echo "Downloading linux binary version: ${cli_version}"
  curl -L https://github.com/openhie/package-starter-kit/releases/download/"$cli_version"/gocli-linux -o platform-linux
  chmod +x ./platform-linux
  exit 0
  ;;
macos)
  echo "Downloading macos binary version: ${cli_version}"
  curl -L https://github.com/openhie/package-starter-kit/releases/download/"$cli_version"/gocli-macos -o platform-macos
  chmod +x ./platform-macos
  exit 0
  ;;
windows)
  echo "Downloading windows binary version: ${cli_version}"
  curl -L https://github.com/openhie/package-starter-kit/releases/download/"$cli_version"/gocli.exe -o platform.exe
  chmod +x ./platform.exe
  exit 0
  ;;
all)
  echo "Downloading all binaries, version: ${cli_version}"
  curl -L https://github.com/openhie/package-starter-kit/releases/download/"$cli_version"/gocli-linux -o platform-linux
  curl -L https://github.com/openhie/package-starter-kit/releases/download/"$cli_version"/gocli-macos -o platform-macos
  curl -L https://github.com/openhie/package-starter-kit/releases/download/"$cli_version"/gocli.exe -o platform.exe
  chmod +x ./platform-linux
  chmod +x ./platform-macos
  chmod +x ./platform.exe
  exit 0
  ;;
--help)
  echo "Usage: get-cli.sh [linux|macos|windows|all] {cli_version}"
  exit 0
  ;;
esac
