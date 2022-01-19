# Jembi Platform

## Prerequisites

- Docker installed
- Golang (cli dev)

## Quick Start for devs (local single node)

1. Ensure that you have the latest instant repository checked out in the same folder that this repo is in.
1. `./build-image.sh` - builds the platform image
1. Initialise Docker Swarm mode: `docker swarm init`
1. Run `go cli` binary to launch the project:

    - **Linux**. From terminal run: `./platform-linux`
    - Mac. From terminal run: `./platform-macos`
        > Warning: Mac has an issue with the binary as it views the file as a security risk
    - Windows. Double click: `platform.exe`

## Go Cli Dev

The Go Cli scripts are kept in the [Instant OpenHIE Repo](https://github.com/openhie/instant/tree/master/goinstant). To make changes to the Cli clone the Instant repo and make your changes in the `goinstant` directory.

To build the go cli for the `platform` project run:

```sh
./build-cli.sh
```

This requires the Instant OpenHIE project to build the binary files. The binary files in the root directory here will be overwritten.

> Only commit your new binary files after your task has been reviewed and approved.
