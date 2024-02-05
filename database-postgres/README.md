
# Instant OpenHIE Postgres database - docker-swarm

## Getting Started

> **The below instructions are only to be used for starting up the Postgres manually for local testing outside of the usual Instant OpenHIE start instructions.**

Proceed with care. This very manual deployment can get complicated.
For the regular start up, please see the [README.md](../../README.md).

### Prerequisites

Ensure that docker is installed. For details on how to install docker click [here](https://linuxize.com/post/how-to-install-and-use-docker-compose-on-ubuntu-18-04/).
For installing docker click [here](https://linuxize.com/post/how-to-install-and-use-docker-on-ubuntu-18-04/).

For our compose scripts to work, one needs to be able to run docker commands without the `sudo` preface. You can configure your system to run without needing the `sudo` preface by running the following command

```bash
./configure-docker.sh
```

### Start Up Postgres Service

From the instant root directory, run the following command to start up the fhir data store.

```bash
./database-postgres/swarm.sh init
```

To take down the service run:

```bash
./database-postgres/swarm.sh destroy
```

To shut down the services run:

```bash
./database-postgres/swarm.sh down
```

To start the services when they have been stopped run:

```bash
./database-postgres/swarm.sh up
```

To run in dev mode in which the ports are exposed pass the flag `--dev` as done below

```bash
./database-postgres/swarm.sh init --dev
```

## Accessing the services

Thid service is accessible on port 5432 when deployed in dev mode.

## Backups

> This section assumes postgres backups are made using `pg_basebackup`

### Postgres

To enable backups, ensure that you have created the Hapi FHIR bind mount directory (eg./backup)

## Disaster Recovery

> NB!!! DO NOT UNTAR OR EDIT THE FILE PERMISSIONS OF THE POSTGRES BACKUP FILE

### Postgres

Preliminary steps:

1. Do a `destroy` of `database-postgres` using the CLI binary (./instant-linux for linux)
1. Make sure the Postgres volumes on nodes other than the swarm leader have been removed as well! You will need to ssh into each server and manually remove them.
1. Do an `init` of `database-postgres` using the CLI binary

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
1. Do a `down` of `database-postgres` using the CLI binary
1. Wait for the `down` operation to complete
1. Do an `init` of `database-postgres` using the CLI binary

Postgres should now be recovered

> Note: after performing the data recovery, it is possible to get an error from services using postgres (eg 500 internal server error for Hapi-fhir) while the data is still being replicated across the cluster. Wait a minute and try again.
