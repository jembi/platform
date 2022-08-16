# Jembi Platform

## Tech Used

- Docker
- Golang (cli dev)
- Terraform (remote cluster setup)
- Ansible (remote cluster setup)

## Quick Start for devs (local single node)

1. If running into an error `invalid mount config for type "bind": bind source path does not exist: /tmp/logs` on running the CLI binary, run the following command: `sudo mkdir -p /tmp/logs/`.
1. `./build-image.sh` - builds the platform image
1. Initialise Docker Swarm mode: `docker swarm init`
1. Run `go cli` binary to launch the project:

    - **Linux**. From terminal run: `./platform-linux`
    - Mac. From terminal run: `./platform-macos`
        > Warning: Mac has an issue with the binary as it views the file as a security risk. See [this article](https://www.lifewire.com/fix-developer-cannot-be-verified-error-5183898) to bypass warning
    - Windows. Double click: `platform.exe`
1. Choose your options and deploy!

## Quick Start for devs (remote cluster)

To set up a remote cluster environment, see [readme](https://github.com/jembi/cloud/blob/main/aws/mercury-team/README.md) in the [cloud repo](https://github.com/jembi/cloud).

1. Ensure that you have the latest instant repository checked out in the same folder that this repo is in.
1. `./build-image.sh` - builds the platform image
1. Add `.env.prod` file with your remote env vars option set.

    > Each Package contains a `metadata.json` file which lists the configurable Env vars and their default values

1. Run `go cli` binary to launch the project (*Make sure to add the `DOCKER_HOST` variable indicating your **lead Swarm manager***, i.e. DOCKER_HOST=ssh://{lead_ip} ./platform-linux):

1. Check the current cli version in `./get-cli.sh` and run to download binaries
    - **Linux**. From terminal run: `./platform-linux`
    - Mac. From terminal run: `./platform-macos`
        > Warning: Mac has an issue with the binary as it views the file as a security risk
    - Windows. Double click: `platform.exe`

1. Choose the **Custom Setup** option
1. Specify your environment variable file (or type them all out :| )
1. Add your package IDs, etc. and deploy!

## Go Cli Dev

The Go Cli scripts are kept in the [OpenHIE Package Start Kit Repo](https://github.com/openhie/package-starter-kit/tree/main/cli). To make changes to the Cli clone the repo and make your changes in the `cli` directory.

To create new binaries, create a new tag and release and then change the cli version in `./get-cli.sh` in the platform repo and run the script to download the latest.

## Platform Package Dev

The Go Cli runs all services from the `jembi/platform` docker image. When developing packages you will need to build your dev image locally with the following command:

```sh
./build-image.sh
```

As you add new packages to the platform remember to list them in `config.yml` file. This config file controls what packages the Go Cli can launch from the UI.

For logging all output to a file, ensure that you have created the file and it has the required permissions to be written to.
The default log file with it's path is set in `.env.local` in `BASHLOG_FILE_PATH`. 
The logPath property in the `config.yml` is used to create a bind mount for the logs to be stored on the host.

## Resource Allocations

The resource allocations for each service can be found in each service's respective docker-compose.yml file under `deploy.resources`. The field `reservations` specifies reserved resources for that service, per container. The field `limits` specifies that maximum amount of resources that can be used by that service, per container.

Each service's resource allocations can be piped into their .yml file through environment variables. Look at the .yml files for environment variable names per service.

### Notes on Resource Allocations

- CPU allocations are specified as a portion of the total number of cores on the host system, i.e., a CPU limit of `2` in a `6-core` system is an effective limit of `33.33%` of the CPU, and a CPU limit of `6` in a `6-core` system is an effective limit of `100%` of the CPU.
- Memory (RAM) allocations are specified as a number followed by their multiplier, i.e., 500M, 1G, 10G, etc.
- Be wary of allocating CPU limits to ELK Stack services. These seem to fail with CPU limits and their already implemented health checks.
- Take note to not allocate less memory to ELK Stack services than their JVM heap sizes.
- Exit code 137 indicates an out-of-memory failure. When running into this, it means that the service has been allocated too little memory.

## Backups

> This section assumes postgres backups are made using `pg_basebackup`

### Postgres (Hapi-FHIR)

To start up Hapi FHIR and ensure that the backups can be made, ensure that you have created the Hapi FHIR bind mount directory (eg./backup)

## Disaster Recovery

> NB!!! DO NOT UNTAR OR EDIT THE FILE PERMISSIONS OF THE POSTGRES BACKUP FILE

### Postgres (Hapi-FHIR)

Preliminary steps:

1. Do a `destroy` of `fhir-datastore-hapi-fhir` using the CLI binary (./platform-linux for linux)
1. Make sure the Postgres volumes on nodes other than the swarm leader have been removed as well! You will need to ssh into each server and manually remove them.
1. Do an `init` of `fhir-datastore-hapi-fhir` using the CLI binary

After running the premilinary steps, run the following commands on the node hosting the Postgres leader:

> NOTE: The value of the `REPMGR_PRIMARY_HOST` variable in your .env file indicates the Postgres leader

1. Retrieve the Postgres leader's container-ID using `docker ps -a`, hereafter called `postgres_leader_container_id`
1. Do `docker exec -t <postgres_leader_container_id> pg_ctl stop -D /bitnami/postgresql/data`
1. Wait for the Postgres leader container to die and start up again... monitor this using `docker ps -a`
1. Do `docker rm <postgres_leader_container_id>`
1. Retrieve the new Postgres leader's container-ID using `docker ps -a`, be weary to not use the old `postgres_leader_container_id`
1. Retrieve the Postgres backup file's name as an absolute path (/backups/postgresql_xxxxxxxxxx), hereafter called `backup_file`
1. Run the following commands in the order listed :
    ```sh
    # Stop the server running in the container
    docker exec -t <postgres_leader_container_id> pg_ctl stop -D /bitnami/postgresql/data

    # Clear the contents of /bitnami/postgresql/data
    docker exec -t --user root <postgres_leader_container_id> sh -c 'cd /bitnami/postgresql/data && rm -rf $(ls)'

    # Copy over the base.tar file
    sudo docker cp <backup_file>/base.tar <postgres_leader_container_id>:/bitnami/postgresql

    # Extract the base.tar file
    docker exec -t --user root <postgres_leader_container_id> sh -c 'tar -xf /bitnami/postgresql/base.tar --directory=/bitnami/postgresql/data'

    # Copy over the pg_wal.tar file
    sudo docker cp <backup_file>/pg_wal.tar <postgres_leader_container_id>:/bitnami/postgresql

    # Extract pg_wal.tar
    docker exec -t --user root <postgres_leader_container_id> sh -c 'tar -xf /bitnami/postgresql/pg_wal.tar --directory=/bitnami/postgresql/data/pg_wal'

    # Copy conf dir over
    docker exec -t --user root <postgres_leader_container_id> sh -c 'cp -r /bitnami/postgresql/conf/. /bitnami/postgresql/data'

    # Set pg_wal.tar permissions
    docker exec -t --user root <postgres_leader_container_id> sh -c 'cd /bitnami/postgresql/data/pg_wal && chown -v 1001 $(ls)'

    # Start the server
    docker exec -t <postgres_leader_container_id> pg_ctl start -D /bitnami/postgresql/data
    ```
1. Do a `down` of `fhir-datastore-hapi-fhir` using the CLI binary
1. Wait for the `down` operation to complete
1. Do an `init` of `fhir-datastore-hapi-fhir` using the CLI binary

Postgres should now be recovered

> Note: after performing the data recovery, it is possible to get an error from hapi-fhir (500 internal server error) while the data is still being replicated across the cluster. Wait a minute and try again.
