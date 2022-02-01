# Jembi Platform

## Tech Used

- Docker
- Golang (cli dev)
- Terraform (remote cluster setup)
- Ansible (remote cluster setup)

## Quick Start for devs (local single node)

1. Ensure that you have the latest instant repository checked out in the same folder that this repo is in.
1. `./build-image.sh` - builds the platform image
1. Initialise Docker Swarm mode: `docker swarm init`
1. Run `go cli` binary to launch the project:

    - **Linux**. From terminal run: `./platform-linux`
    - Mac. From terminal run: `./platform-macos`
        > Warning: Mac has an issue with the binary as it views the file as a security risk. See [this article](https://www.lifewire.com/fix-developer-cannot-be-verified-error-5183898) to bypass warning
    - Windows. Double click: `platform.exe`
1. Choose your options and deploy!

## Quick Start for devs (remote cluster)

To set up a remote cluster environment, see [mercury readme](https://github.com/jembi/cloud/blob/main/aws/mercury-team/README.md) in the [cloud repo](https://github.com/jembi/cloud).

1. Ensure that you have the latest instant repository checked out in the same folder that this repo is in.
1. `./build-image.sh` - builds the platform image
1. Add `.env.prod` file with your remote env vars option set.
*Make sure to add the `DOCKER_HOST` variable indicating your **lead Swarm manager***

    > Each Package contains a `metadata.json` file which lists the configurable Env vars and their default values

1. Run `go cli` binary to launch the project:

    - **Linux**. From terminal run: `./platform-linux`
    - Mac. From terminal run: `./platform-macos`
        > Warning: Mac has an issue with the binary as it views the file as a security risk
    - Windows. Double click: `platform.exe`

1. Choose the **Custom Setup** option
1. Specify your environment variable file (or type them all out :| )
1. Add your package IDs, etc. and deploy!

## Go Cli Dev

The Go Cli scripts are kept in the [Instant OpenHIE Repo](https://github.com/openhie/instant/tree/master/goinstant). To make changes to the Cli clone the Instant repo and make your changes in the `goinstant` directory.

To build the go cli for the `platform` project run:

```sh
./build-cli.sh
```

This requires the Instant OpenHIE project to build the binary files.

## Platform Package Dev

The Go Cli runs all services from the `jembi/platform` docker image. When developing packages you will need to build your dev image locally with the following command:

```sh
./build-image.sh
```

As you add new packages to the platform remember to list them in `/platform-cli-conf/config.yml` file. This config file controls what packages the Go Cli can launch from the UI.
